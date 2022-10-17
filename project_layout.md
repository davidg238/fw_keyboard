The original post on [creating a Toit Library](https://ekorau.com/2021/09/09/Creating-Library-Example.html) was written a year ago, when Toit was only offered as closed source.  Since then, the [Toit language](https://github.com/toitlang) has been open sourced and [Jaguar](https://github.com/toitlang/jaguar) tooling added. What follows is an update of the original article, to reflect the usage of Jaguar v1.7.1, to revise and run the project [FW_Keyboard](https://github.com/davidg238/fw_keyboard).

1) The .yaml and .lock files and the hidden .packages directories (under project root, examples and tests) were deleted.

Refering to the repository [FW_Keyboard](https://github.com/davidg238/fw_keyboard)  
The core code layout looks like :  
```
fw_keyboard
|
├── CHANGELOG.md
├── examples
│   └── terminal_demo.toit
├── LICENSE
├── README.md
├── src
│   ├── bbq10keyboard.toit
│   ├── events.toit
│   └── fw_keyboard.toit
└── tests
    ├── fw_display_test.toit
    └── fw_keyboard_test.toit

```
## In the *project root* directory:
2) To create the (empty) **package.yaml** and **package.lock** files run  
    `jag pkg init`  
   There is no response to this command.

3) To declare the external dependencies of the library *src* code, run  
    `jag pkg install github.com/toitware/toit-color-tft`  
    the response is  
    `Info: Package 'github.com/toitware/toit-color-tft@1.3.0' installed with name 'color_tft'`  
    then run  
    `jag pkg install github.com/toitware/toit-pixel-display`  
    the response is  
    `Info: Package 'github.com/toitware/toit-pixel-display@1.6.0' installed with name 'pixel_display'`  
    then run  
    `jag pkg install github.com/toitware/toit-pixel-strip`
    the response is  
    `Info: Package 'github.com/toitware/toit-pixel-strip@0.2.0' installed with name 'pixel_strip'`

4) If the library is to be shared, edit *package.yaml* adding a `name:` and `description:` entry.
   *package.yaml* then looks like:
```
name: fw_keyboard
description: A library for the Keyboard FeatherWing Rev 2.
dependencies:
  color_tft:
    url: github.com/toitware/toit-color-tft
    version: ^1.3.0
  pixel_display:
    url: github.com/toitware/toit-pixel-display
    version: ^1.6.0
  pixel_strip:
    url: github.com/toitware/toit-pixel-strip
    version: ^0.2.0
```
   The named dependencies `color_tft` and `pixel_display` correspond to the imports in the library *src*, so for example in the *src/keyboard_driver.toit* file:
   ```
   import color_tft show ColorTft COLOR_TFT_16_BIT_MODE
   import pixel_display show TrueColorPixelDisplay
   ```
## In the *src* directory:  
5) No `jag pkg` actions are required.  
   External library dependencies are already captured in the project root *package.yaml* file.  
   To make your library easier to use, make a file matching the library name, like `fw_keyboard.toit`, contents:  
```
import .bbq10keyboard
import .events
import .keyboard_driver
import .touch_controller

export *
```
   Note, the contents of the source directory are exported.
   Dependencies between files in the library, are by relative import.  
   For example, in *keyboard_driver.toit*, the `BBQ10Keyboard` class is imported as:  
   `import .bbq10keyboard show BBQ10Keyboard`

## In the *tests* directory:
The **tests** directory contains code meant to test your library and would not be called by other developers.  As application code, a *package.lock* file is required and is specific to the directory.

6) To create a package.lock, run  
    `jag pkg init`  

7) To populate the dependencies, run  
    `jag pkg install --local --name fw_keyboard ..`  
    the response is  
    `Info: Package '..' installed with name 'fw_keyboard'`  
    then run  
    `jag pkg install github.com/toitware/toit-color-tft`  
    `jag pkg install github.com/toitware/toit-pixel-display`  
    `jag pkg install github.com/toitware/toit-pixel-strip`  
    Dependency to the library code under construction is declared in the first install, the name is explicit.  
    Dependencies to external libraries is declared in the succeeding installs.  

   The *package.yaml* in the tests directory now looks like:
```
dependencies:
  color_tft:
    url: github.com/toitware/toit-color-tft
    version: ^1.3.0
  fw_keyboard:
    path: ..
  pixel_display:
    url: github.com/toitware/toit-pixel-display
    version: ^1.6.0
  pixel_strip:
    url: github.com/toitware/toit-pixel-strip
    version: ^0.2.0
```   

8) From the **test** directory, run a test:  
   `jag run fw_display_test.toit`  

## In the *examples* directory:
9) To create a package.lock, run  
    `jag pkg init`  

10) To populate the dependencies, run  
    `jag pkg install --local --name fw_keyboard ..`  
    `jag pkg install toit-font-google-100dpi-roboto`  
    `jag pkg install github.com/toitware/toit-color-tft`  
    `jag pkg install github.com/toitware/toit-pixel-display`  
    `jag pkg install github.com/toitware/toit-pixel-strip`    

11) From the **example** directory, run the example:  
   `jag run demo.toit`

12) Add a `.gitignore` file in the project root directory, as the (hidden) package directories must not versioned into the repository.  Looks like:  
```
.packages/
examples/.packages
tests/.packages
```

The final library code structure looks like:  

```
.
├── CHANGELOG.md
├── examples
│   ├── terminal_demo.toit
│   ├── package.lock        
│   ├── .packages           
│   └── package.yaml
├── .gitignore              
├── LICENSE
├── .packages               
│   ├── github.com
│   └── README.md
├── package.lock
├── package.yaml            
├── README.md
├── src
│   ├── bbq10keyboard.toit
│   ├── events.toit
│   ├── fw_keyboard.toit
│   ├── keyboard_driver.toit
│   └── touch_controller.toit
└── tests
    ├── fw_display_test.toit
    ├── fw_keyboard_test.toit
    ├── package.lock        
    ├── .packages           
    └── package.yaml

```