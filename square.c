/*
Name: Nick Sica
File: square.c
Email: nsica1@umbc.edu
Descritpion: Gets the square root of a value. 
*/

#include <stdio.h>
#include <math.h>

int square(int value)
{
  int result = 0;
  //gets square root
  result = sqrt(value);

  //print
  printf("Enter jump interval between 2-%d->\n", result);
  
  return result;
}
