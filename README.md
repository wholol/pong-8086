# Pong-8086 (WIP!)
pong game in x86 assembly (8086). Player 1 uses w and a keys, Player 2 uses o and l keys to move the bat.

## Dependencies  
Requires 8086 assembler and DOSBox

## Installation:
### step 1: Create a folder called pong on C drive:
```
mkdir pong
```
### step 2: clone repo in the folder
```
cd pong
git clone https://github.com/wholol/pong-8086
```
### step 3: download dependencies
Download <a href="https://www.dosbox.com/download.php?main=1">DOSBox</a>
Download <a href="https://drive.google.com/drive/folders/1akM4UNg6StiVE3ehzEstOgOhEw1JBxA0">8086 assembler</a>
### step 4: unzip/extract assembler into same path as pong.asm
### step 5: Open DOSBox and mount the file path onto the Z Drive by entering:
```
mount C C:\pong
```
### step 6: navigate to file path
### step 7: enter the command into DOSBox:
```
masm
```
### step 8: set sourcefilename as pong, press enter for other entries:
### step 9: enter the command into DOSBox:
```
link pong
```
### step 10: press enter for all entries:
### step 11: enter the command into DOSBox:
```
pong
```
