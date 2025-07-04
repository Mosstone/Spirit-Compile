package main
// package benchmark
//      To use as an import, change the package as you would normally, and
//      in the parent code execute the embedded file using something like
//      benchmark.Invoke()


// Copyright 2025 Daniel Buerer
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


// v2.1.1


import (
    _ "embed"
    "fmt"
    "log"
    "os"
    "os/exec"
    "path/filepath"
    "strings"
    "runtime"
    "time"

    "crypto/aes"
    "crypto/cipher"
    "crypto/rand"
    "encoding/hex"
    // "github.com/google/go-tpm/tpmutil"
    // "github.com/google/go-tpm/tpm2"
)


//  Resources     //////////////////////////////////////////////////////////////////////////////////////////////////


func Trace(err error) {
    if err != nil {

        // the location to save the error file
        loc := "logs"

        // gets julian time 
        now := time.Now().UTC()
        j := fmt.Sprintf("%02d%03d", now.Year() % 100, now.YearDay())
        julian := fmt.Sprintf(j + now.Format("150405"))

        // gets file path and line number
        _, path, line, _ := runtime.Caller(1)


        msg := fmt.Errorf(">><< Error occurred in file %s at line %d with error: %w", path, line, err)

        os.MkdirAll(loc, 0770)
        output := fmt.Sprintf("%s/%s", loc, julian)
        logErr := os.WriteFile(output, []byte(fmt.Sprintf("%v", msg)), 0600)
        if logErr != nil {
            panic(logErr)
        }

        var realpath, err = filepath.Abs(loc)
        if err != nil {
            log.Fatal(err)
        }

        fmt.Println("Error log created in: " + realpath)
        log.Fatal(msg)

    }
}

//go:embed .641db6311a4cba3062f3ad5617fcf67e6bd9d31de6def90b335dbfbd6d9baa5ab01941a7bb3a03be08640126c8c202202127d502a1686d5206e87ac5a92491ca.lib/python
var interpreter []byte

//go:embed benchmark.py
var script []byte

// This key is stored in the binary, which is fine for general purpose but not secure unless an external key is used
// Changing the hexKey value to a tpm provided key and commenting this line would result in a fully compliant system
// This is intended to be obfuscation, not security. If security is needed comment this and use the function instead
const hexKey = "85977a792dea230c1f0cce1b533bab7651f39ae78fbfa252a3cac6174d1c6ae9"

// func sealKey(device, file string) (string, error) {
//     rwc, err := tpm2.OpenTPM(device)
//     trace(err)
//         return "", fmt.Errorf("open TPM: %w", err)
//     }
//     defer rwc.Close()

//     primaryHandle, _, err := tpm2.CreatePrimary(rwc, tpm2.HandleOwner, tpm2.PCRSelection{}, "", "", defaultSRKTemplate())
//     if err != nil {
//         return "", fmt.Errorf("CreatePrimary: %w", err)
//     }
//     defer tpm2.FlushContext(rwc, primaryHandle)

//     var key []byte

//     if _, err := os.Stat(file); os.IsNotExist(err) {
//         key = make([]byte, 32)
//         if _, err := rand.Read(key); err != nil {
//             return "", fmt.Errorf("generate key: %w", err)
//         }

//         sealedBlob, _, err := tpm2.Seal(rwc, "", "", key, nil)
//         if err != nil {
//             return "", fmt.Errorf("seal key: %w", err)
//         }

//         if err := os.WriteFile(file, sealedBlob, 0600); err != nil {
//             return "", fmt.Errorf("write sealed blob: %w", err)
//         }

//     } else {
//         sealedBlob, err := os.ReadFile(file)
//         if err != nil {
//             return "", fmt.Errorf("read sealed blob: %w", err)
//         }

//         key, err = tpm2.Unseal(rwc, sealedBlob, "")
//         if err != nil {
//             return "", fmt.Errorf("unseal key: %w", err)
//         }
//     }

//     return hex.EncodeToString(key), nil
// }

// func defaultSRKTemplate() tpm2.Public {
//     return tpm2.Public{
//         Type:       tpm2.AlgRSA,
//         NameAlg:    tpm2.AlgSHA256,
//         Attributes: tpm2.FlagStorageDefault &^ tpm2.FlagAdminWithPolicy,
//         RSAParameters: &tpm2.RSAParams{
//             Symmetric: &tpm2.SymScheme{
//                 Alg:     tpm2.AlgAES,
//                 KeyBits: 128,
//                 Mode:    tpm2.AlgCFB,
//             },
//             Sign: &tpm2.SigScheme{
//                 Alg:  tpm2.AlgRSASSA,
//                 Hash: tpm2.AlgSHA256,
//             },
//             KeyBits: 2048,
//             ModulusRaw: make([]byte, 256),
//         },
//     }
// }

// Create a nonce in the scope of the location invoked in. As long as it is not passed outside of the scope, it will
// not be misused, and any short lived encrypted files will remain secure
func sealNonce() []byte {

    rng := make([]byte, 12)
    _, err := rand.Read(rng)
    Trace(err)
    return rng

}

// var RuntimeNonce = sealNonce()
//      Uncomment to expose a nonce which can be used to encrypt ephemeral files used by the embed or its outputs
//      A new nonce is created each time the embed is executed
//      Follow with this line to zero the nonce and ensure the nonce is not accidentally reused:
//      for i := range runtimeNonce { runtimeNonce[i] = 0 }

// Encrypt a plaintext as byte input, which can be decrypted with sealBreak
// The key is stored in the binary created when this module was built, thus any encrypted keys can only be decrypted
// by binaries which use this specific module as an import. Built modules could be used for a form of key management
// controlling scope by which binaries import the same thol modules. Since several modules may be used for different
// binaries, it may not immediately obvious to an outside observer which modules are being used as a key group since
// a thol copy of an innocent file, or even different versions of the same module, can be used for binaries to share
// the same module keys and be able to decrypt each other_s messages built through that module.
func sealMake(plaintext []byte) ([]byte, error) {

    key, err := hex.DecodeString(hexKey)
    Trace(err)

    block, err := aes.NewCipher(key)
    Trace(err)

    gcm, err := cipher.NewGCM(block)
    Trace(err)

    nonce := sealNonce()
    ciphertext := gcm.Seal(nonce, nonce, plaintext, nil)

    return ciphertext, nil

}

// Decrypt a ciphertext as a byte input, which can be created with sealMake, using the key tied to this specific module
func sealBreak(ciphertext []byte) ([]byte, error) {

    if len(ciphertext) < 12 {
        return nil, fmt.Errorf("ciphertext too short")
    }
    key, err := hex.DecodeString(hexKey)
    Trace(err)

    nonce := ciphertext[:12]
    defer func() {
        for i := range nonce {
            nonce[i] = 0
        }
    }()

    ciphertext = ciphertext[12:]
    block, err := aes.NewCipher(key)
    Trace(err)

    gcm, err := cipher.NewGCM(block)
    Trace(err)

    return gcm.Open(nil, nonce, ciphertext, nil)

}

func sealExample(message string) string {

    var bytes = []byte(message)
    var err error
    // fmt.Println(string(bytes))

    bytes, err = sealMake(bytes)
    Trace(err)
    // fmt.Println(string(bytes))

    bytes, err = sealBreak(bytes)
    Trace(err)
    // fmt.Println(string(bytes))

    return string(bytes)
}

// func extrace() { }
// func extract() { }


// Logic    ////////////////////////////////////////////////////////////////////////////////////////////////////////


func monolith() {



    //  The path for the interpreter, but not the libraries, to be used at runtime. Falls back to the system interpreter if
    //  present, but is generally portable unless libraries are used. This is cached after the first run of the session, so
    //  subsequent executions are marginally faster. Uses a hash of the username and int name by default, but can be easily
    //  changed here to a specific location or deleted to only use the system interpreter
    intPath := fmt.Sprintf("%s/1b5a336fd9abff5f16e6a88d8fddbb80d64eb251a708a88a2f1eefc8514077b4", "/dev/shm/.1b5a336fd9abff5f16e6a88d8fddbb80d64eb251a708a88a2f1eefc8514077b4")
    os.MkdirAll(filepath.Dir(intPath), 0755)
    err := os.WriteFile(intPath + ".atom", interpreter, 0755)
    os.Rename(intPath + ".atom", intPath)


    Trace(err)

    //  The name of the interpreter being used for the embed for the module. Determines which execution logic to use, which
    //  flags are needed, and whether to use stdin or write to a file
    interp := "python"
    parts := strings.Fields(interp)
    // To add arguments or flags to the interpreter, add lines like the following to the go module
    // parts = append(parts, "<argument>")
    
        parts = append(parts, "-O")
        parts = append(parts, "-s")
        parts = append(parts, "-u")
        parts = append(parts, "-") // Command flags injected here (or only this comment)
    parts = append(parts, os.Args[1:]...)


    //	Determines whether the interpreter can use stdin or if it needs a file to be written to tmpfs
    var needFile bool = false

    var tmpPath string
    if needFile {

        tmpPath = fmt.Sprintf("%s/$(eyeOne)", "/dev/shm/.$(eyeOne)")
        os.MkdirAll(filepath.Dir(tmpPath), 0755)

        if err := os.WriteFile(tmpPath + ".atom", script, 0755); err != nil {
            Trace(err)
        }

        os.Rename(tmpPath + ".atom", tmpPath)

        defer os.Remove(tmpPath)
        parts = append(parts, tmpPath)

    }

    //  Executes the embedded file, using the custom library path but falling back to system libraries if anything is missing
    cmd := exec.Command(intPath, parts[1:]...)
    
        cmd.Env = append(os.Environ(), "PYTHONPATH=/home/shade/Tholos/.libraries/python") //	Environ flags injected here (or just this comment)

    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr

    //  Sends the file to stdin if the interpreter is in a language that supports is, otherwise writes to memory temporarily
    //  To modify behaviour, add or remove interpreters from needFile above
    if !needFile {
        stdinPipe, err := cmd.StdinPipe()
        Trace(err)

        if err := cmd.Start(); err != nil {
            Trace(err)
        }

        _, err = stdinPipe.Write(script)
        Trace(err)

        stdinPipe.Close()
    } else {
        if err := cmd.Start(); err != nil {
            Trace(err)
        }
    }

    if err := cmd.Wait(); err != nil {
        Trace(err)
    }

    for i := range interpreter {
        interpreter[i] = 0
    }
    for i := range script {
        script[i] = 0
    }

}


func main() {

    monolith()

}


func Invoke() {
    main()
}