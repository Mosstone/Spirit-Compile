package main
// package Makefile
//     To use as an import, swap the comments and in the binary main run the embedded script as Makefile.Invoke()
//     This will run the embedded script as if it were executed in cli with the interpreter, using the flags defined
//     Output goes to os.stdout by default in either case, this can be redefined with the cmd.Stdout = <output> line
//     This suggested name is dynamically assigned by Tholos based on the module name, for duplicate modules setting
//     unique name for files (i.e. using a hash or nanosecond timer) will allow the suggested name to also be unique
//     so they can all be imported.


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


// v1.5


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

// Alternative error handling function, more robust and concise than typical blocks. Also available in .modules as a
// dot import, but supplied here to keep the thol portable. Just add Trace(err) after anything with an err output to
// to satisfy compiler requirements. This is a fail first method creating a log file in pwd indicating the error and
// line number in the 'locs' folder. To specify change the loc value to point to the path that fails should point to
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


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


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

//go:embed .23569a28c3efae2f7b66976bbf2f53e1ddd5dbaca3494a4c902a09332efe76d3fc2e03decf42854132adc52afd5a60b9058c9d4fb310aad3e39494f740e2f3ee.lib/make
var interpreter []byte

//go:embed Makefile
var script []byte

// This key is stored in the binary, which is fine for general purpose but not secure unless an external key is used
// Changing the hexKey value to a tpm provided key and commenting this line would result in a fully compliant system
// This is intended to be obfuscation, not security. If security is needed comment this and use the function instead
const hexKey = "408311b2e1ce0014729b27c3567c3819a8fa09755433cea5f7b920507fd642e8"

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

func execute() {

//  The path for the interpreter, but not the libraries, to be used at runtime. Falls back to the system interpreter if
//  present, but is generally portable unless libraries are used. This is cached after the first run of the session, so
//  subsequent executions are marginally faster. Uses a hash of the username and int name by default, but can be easily
//  changed here to a specific location or deleted to only use the system interpreter
    intPath := fmt.Sprintf("%s/083ed2aedc1c8dd293faea7f8e86238db1ed94e5070698503f77ee656b19f84d", "/dev/shm/.083ed2aedc1c8dd293faea7f8e86238db1ed94e5070698503f77ee656b19f84d")
os.MkdirAll(filepath.Dir(intPath), 0755)
err := os.WriteFile(intPath, interpreter, 0755)
Trace(err)

//  The name of the interpreter being used for the embed for the module. Determines which execution logic to use, which
//  flags are needed, and whether to use stdin or write to a file
    interp := "make"
parts := strings.Fields(interp)
    // To add arguments or flags to the interpreter, add lines like the following to the go module
    // parts = append(parts, "<argument>")
    
parts = append(parts, "-f") // Command flags injected here (or only this comment)
parts = append(parts, os.Args[1:]...)


//	Determines whether the interpreter can use stdin or if it needs a file to be written. Consider setting this to static
//  needsFile = true if a real file is required. Any tmp file created will be encrypted and then deleted by default, this
//  can be changed to cache the file instead farther down. Notably, this is fully compatible with sealMake and works fine
//  if executed outside of an embed, subject to aes encryption standards.
var needsFile bool
switch interp {
case "rust-script", "deno", "Rscript", "scala", "wolframscript", "racket", "lualatex", "make", "ansible-playbook":
needsFile = true
default:
needsFile = false
} //  fmt.Println(needsFile)

var tmpPath string
if needsFile {

        tmpPath = fmt.Sprintf("%s/2623d699fa29aeddaa8af0fa2c4a2c01b128bdfb2ebde5c7e4cebea31b4f1d5c", "/dev/shm/.2623d699fa29aeddaa8af0fa2c4a2c01b128bdfb2ebde5c7e4cebea31b4f1d5c/")
os.MkdirAll(filepath.Dir(tmpPath), 0755)

if err := os.WriteFile(tmpPath, script, 0755); err != nil {
Trace(err)
}

defer os.Remove(tmpPath)
parts = append(parts, tmpPath)

}

//  Executes the embedded file, using the custom library path but falling back to system libraries if anything is missing
cmd := exec.Command(intPath, parts[1:]...)
 //	Environ flags injected here (or just this comment)

cmd.Stdout = os.Stdout
cmd.Stderr = os.Stderr

//  Sends the file to stdin if the interpreter is in a language that supports is, otherwise writes to memory temporarily
//  To modify behaviour, add or remove interpreters from needsFile above
if !needsFile {
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

    // extract()
    execute()
// extrace()

}


func Invoke() {
main()
}


