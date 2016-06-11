#!/bin/bash

if [ $# -eq 0 ]; then
    echo "[x] ERROR: Provide as input a string message which length must be less than 447 bits (max 55 characters)"
    exit 1
fi

write_address=(
  0x40000004
  0x40000008
  0x4000000c
  0x40000010
  0x40000014
  0x40000018
  0x4000001c
  0x40000020
  0x40000024
  0x40000028
  0x4000002c
  0x40000030
  0x40000034
  0x40000038
  0x4000003c
  0x40000040
)

read_address=(
  0x40000048
  0x4000004c
  0x40000050
  0x40000054
  0x40000058
  0x4000005c
  0x40000060
  0x40000064
)

# not usable since on the Zybo there is no xxd installed
# message=$(printf $1 | xxd -b | awk -F " " '{for(i=2; i<NF; i++) print $i}' | tr -d "\n")

# prints the decimal values of the characters
input=$(printf $1 |  od -A n -t uC)

# convert the decimal numbers in binary
for byte in $input
do
  binrep=$(printf $byte | awk '{r="";a=$1;while(a){r=a%2r;a=int(a/2)}printf"%08d\n",r}')
  message+=$binrep
done

echo $message

length=${#message}

if [[ $length -gt 447 ]]; then
  echo "[x] ERROR: The length of the message must be less than 447 bits (max 55 characters)"
  exit -1
fi

# append 1
message+='1'

# calculate how many trailing zeros to append before the length
k=$((448-$length-1))

# add k trailing zeros
for (( i = 0; i < $k; i++ )); do
  message+='0'
done

# convert the length in a 0-padded, 64-bit binary value
binary_length=$(printf $length | awk '{r="";a=$1;while(a){r=a%2r;a=int(a/2)}printf"%064d\n",r}')

# append the binary-represented length
message+=$binary_length

# new length must be 512 bit
new_length=${#message}

if [[ $new_length -ne 512 ]]; then
  echo "[x] ERROR: Padding error"
  exit -1
fi

echo "[ ] Message padded"

# split the binary message in 32-bit long words
split_message=$(printf $message | fold -w 32)

# convert the words of the message in hexadecimal 
for word in $split_message
do
  split_message_hex+=$(printf '0x%08x ' "$((2#$word))")
done

echo "[ ] Hex 32-bit words generated"


echo ""
echo "[ ] Writing sequence initialised"
echo ""

cnt=0
for Mj in $split_message_hex
do
  echo "Writing $Mj at address ${write_address[cnt]}..."
  devmem ${write_address[cnt]} 32 $Mj
  cnt=$((cnt + 1))
done

echo ""
echo "[ ] Sending the start command"
echo ""
echo devmem 0x40000044 32 0x00000000

sleep 1

echo ""
echo "[ ] Reading sequence initialised"
echo ""

for ((i = 0; i < 8; i++)) do
  echo "Reading from address ${write_address[i]}..."
  final_hash+=$(devmem ${read_address[i]} 32)
done        
            
echo ""     
echo "[ ] Finish! :)"
echo ""     
            
echo "The final hash value is"
echo $(echo $final_hash | sed s/0x//g)
