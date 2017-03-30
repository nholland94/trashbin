#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

const size_t STACK_SIZE = 30000;

char * read_codebank_from_file(char *filename) {
  FILE *file = fopen(filename, "rb");
  fseek(file, 0, SEEK_END);
  long file_size = ftell(file);
  fseek(file, 0, SEEK_SET);

  char *file_contents = malloc(file_size);
  if(file_contents == NULL) {
    printf("Unable to allocate string!\n");
    exit(1);
  }

  fread(file_contents, file_size, 1, file);
  fclose(file);

  int brainfuck_character_count = 0;
  for(size_t i = 0; i < file_size; i++) {
    switch(file_contents[i]) {
    case '+':
    case '-':
    case '<':
    case '>':
    case ',':
    case '.':
    case '[':
    case ']':
      brainfuck_character_count++;
    }
  }

  char *codebank = malloc(brainfuck_character_count + 1);
  if(codebank == NULL) {
    free(file_contents);
    printf("Unable to allocate string!\n");
    exit(1);
  }
  codebank[brainfuck_character_count] = 0;

  size_t codebank_offset = 0;
  for(size_t file_contents_offset = 0; file_contents_offset < file_size; file_contents_offset++) {
    char character = file_contents[file_contents_offset];
    switch(character) {
    case '+':
    case '-':
    case '<':
    case '>':
    case ',':
    case '.':
    case '[':
    case ']':
      codebank[codebank_offset++] = character;
    }
  }

  free(file_contents);
  return codebank;
}

void run_program(char *codebank) {
  uint8_t *stack = calloc(1, STACK_SIZE);
  if(stack == NULL) {
    printf("Unable to allocate stack!\n");
    exit(1);
  }

  size_t stack_offset = 0;

  // TODO: better jump stack
  size_t jump_stack[255];
  size_t jump_stack_index = 0;

  char character;
  for(size_t codebank_offset = 0; 1; codebank_offset++) {
    character = codebank[codebank_offset];
    if(character == 0) {
      printf("done\n");
      break;
    }

    switch(character) {
    case '+':
      stack[stack_offset]++;
      break;

    case '-':
      stack[stack_offset]--;
      break;

    case '<':
      if(stack_offset > 0) {
        stack_offset--;
      }

      break;

    case '>':
      if(stack_offset < (STACK_SIZE - 1)) {
        stack_offset++;
      }

      break;

    case ',':
      stack[stack_offset] = (uint8_t)getchar();
      break;

    case '.':
      printf("%c", stack[stack_offset]);
      break;

    // There's a bug with this, but I'm too lazy to fix it.
    // [ [ ] ] In this scenario, the first '[' would skip to the first ']', not the second.
    // Need to do some kind of parsing ahead of time to keep skips within loops fast anyway. This is too slow.
    case '[':
      if(stack[stack_offset] != 0) {
        if(jump_stack_index == 254) {
          printf("\nMax jump stack size exceeded.\n");
          exit(1);
        }

        jump_stack[++jump_stack_index] = codebank_offset - 1;
      } else {
        int search_depth = 0;
        while(1) {
          character = codebank[++codebank_offset];

          if(character == '[') {
            search_depth++;
          }

          if(character == ']') {
            if(search_depth == 0) {
              break;
            } else {
              search_depth--;
            }
          }
        }
      }

      break;

    case ']':
      if(jump_stack_index == 0) {
        printf("\nNo matching '[' for ']'");
      }

      codebank_offset = jump_stack[jump_stack_index--];
      break;
    }
  }

  // ensure program has finished outputing
  fflush(stdout);

  // clear jump stack
  while(jump_stack_index != -1) {
    jump_stack[jump_stack_index--] = 0;
  }

  free(stack);
}

int main(int argc, char *argv[]) {
  if(argc < 2) {
    printf("No brainfuck file specified\n");
    return 1;
  }

  char *codebank = read_codebank_from_file(argv[1]);
  run_program(codebank);

  free(codebank);
  return 0;
}
