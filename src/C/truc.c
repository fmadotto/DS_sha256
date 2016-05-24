// Copyright (c) 2016 Federico Madotto and Coline Doebelin
// federico.madotto (at) gmail.com
// coline.doebelin (at) gmail.com
// https://github.com/fmadotto/DS_bitcoin_miner

// truc.c is part of DS_bitcoin_miner.

// DS_bitcoin_miner is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// DS_bitcoin_miner is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <inttypes.h>

// Base address of registers
#define REGS_ADDR 0x40000000
#define REGS_PAGE_SIZE 8UL
#define REGS_ADDR_MASK (REGS_PAGE_SIZE - 1)
// Base address of DDR (when accessed across the PL)
#define MEM_ADDR 0x80000000
#define MEM_PAGE_SIZE 0x40000000UL
#define MEM_ADDR_MASK (MEM_PAGE_SIZE - 1)

off_t phys_addr[2] = {REGS_ADDR, MEM_ADDR}; // Physical addresses
unsigned long page_size[2] = {REGS_PAGE_SIZE, MEM_PAGE_SIZE}; // Pages sizes
void *virt_addr[2]; // Virtual addresses
int size;

int main(int argc, char **argv) {
  unsigned p, len, min, max, i, j;
  char *str, *mem;
  uint32_t M[16]
  char buff[8]; 
  int fd;
  int st;
  uint32_t *regs;

  st = 0; // Exit status if equal 1 means error
  while(1) { // Just a trick used for error management
    if(argc != 2) { // If not the right number of arguments...
      fprintf(stderr, "usage: %s <string>\n", argv[0]);
      st = 1;
      break;
    }
    // Verify the size of the input
    // put it in 16 variable
      
      
    input = argv[1]; // String to search for
      
    for (i=0; i<16 ; i++) {
        for (j=0; j<8; j++){
            buff[j]=input[(i*16)+j];   
        }
        M[16]=(uint32_t)buff
    }
    
      
    if (len = strlen(input) != 128) {
        fprintf(stderr, "not the good length, have to padding\n");
        st = 1;
        break;
    }
    
    
    fd = open("/dev/mem", O_RDWR | O_SYNC); // Open dev-mem character device
    if(fd == -1) { // If cannot open...
      fprintf(stderr, "cannot open /dev/mem\n");
      st = 1;
      break;
    }
    for(p = 0; p < 2; p++) { // For all regions to map (2 only: registers and DDR)...
      virt_addr[p] = mmap(0, page_size[p], PROT_READ | PROT_WRITE, MAP_SHARED, fd, phys_addr[p]); // Map region
      if(virt_addr[p] == (void *) -1) { // If cannot map...
        fprintf(stderr, "cannot map memory\n");
        st = 1;
        break;
      }
    }
    if(p != 2) { // If could not map all regions...
      st = 1;
      break;
    }
    regs = (uint32_t *)(virt_addr[0]); // Registers region
    mem = (char *)(virt_addr[1]); // DDR region
    printf("Hello SAB4Z\n"); // Print welcome message
    printf("  0x%08x: %08x (STATUS)\n", REGS_ADDR, regs[0]); // Print content of status register
    printf("  0x%08x: %08x (R)\n", REGS_ADDR + 4, regs[1]); // Print content of r register
    
    for (i=0; i<16; i++){
        regs[i+1]=M[0];       
    
    }
    //regs[1] = 0x12345678; // Write r register
    printf("  0x%08x: %08x (STATUS)\n", REGS_ADDR, regs[0]); // Print content of status register
    printf("  0x%08x: %08x (R)\n", REGS_ADDR + 4, regs[1]); // Print content of r register
    
    printf("Bye! SAB4Z\n"); // Print good bye message
    close(fd); // Close dev-mem character device
    for(p = 0; p < 2; p++) { // For all memory regions...
      if(munmap(virt_addr[p], page_size[p]) == -1) { // If cannot unmap region...
        fprintf(stderr, "cannot unmap memory\n");
        st = 1;
      }
    }
    break; // This is the end 
  }
  return st; // Return exit status (0: no error)
}
