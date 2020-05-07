/* #undef __STDC__ */
#include <stdio.h>
#include <stdlib.h>

int tigermain(int arg);

int *initArray(int size, int init)
{
  if (size <= 0) {
    printf("%s\n", "runtime error: array size must be positive");
    exit(1);
  }
  int i;
  int *a = (int *) malloc( (size + 1) * sizeof(int) );
  if (a == NULL) {
    printf("%s\n", "runtime error: memory allocation failed");
    exit(1);
  }
  a[0] = size; // store size
  for(i = 1;i <= size;i++) 
    a[i]=init;
  return a + 1;
}

void checkArrayBounds(int* arr, int index) {
  int size = arr[-1];
  if (index < 0 || index >= size) {
    printf("runtime error: array subscript %d out of bounds %d", index, size);
    exit(1);
  }
}

int *allocRecord(int size)
{
  int i;
  int *p, *a;
  p = a = (int *) malloc(size);
  if (a == NULL) {
    printf("%s\n", "runtime error: memory allocation failed");
    exit(1);
  }
  for( i = 0; i < size; i += sizeof(int) )
    *p++ = 0;
  return a;
}

void checkNilRecord(int *record) {
  if (record == NULL) {
    printf("%s\n", "runtime error: cannot access field of nil record");
    exit(1);
  }
}

struct string {
  int length; 
  unsigned char chars[1];
};

int stringEqual(struct string *s, struct string *t)
{
  int i;
  if (s == t) 
    return 1;
  if (s->length != t->length) 
    return 0;
  for(i = 0; i < s->length; i++) {
    if (s->chars[i] != t->chars[i]) 
      return 0;
  }
  return 1;
}

int stringLessThan (struct string *s, struct string *t)
{
  int i, lt=1;
  if (s->length >= t->length) { 
    struct string *temp = s; 
    s = t; 
    t = temp;
    lt = !lt;
  }
  for(i = 0; i < s->length; i++) {
    if (s->chars[i] < t->chars[i]) 
      return lt;
    else if (s->chars[i] > t->chars[i]) 
      return !lt;
  }
  return lt;
}

void print(struct string *s)
{
  int i; 
  unsigned char *p = s->chars;
  for (i = 0; i < s->length; i++, p++) 
    putchar(*p);
}

void flush()
{
  fflush(stdout);
}

struct string consts[256];
struct string empty = {0, ""};

int main()
{
  int i;
  for(i = 0; i < 256; i++) {
    consts[i].length = 1;
    consts[i].chars[0] = i;
  }
  int res = tigermain(0);
  return res;
}

int ord(struct string *s)
{
  if (s->length == 0) 
    return -1;
  else 
    return s->chars[0];
}

struct string *chr(int i)
{
  if (i < 0 || i >= 256) {
    printf("chr(%d) out of range\n", i); 
    exit(1);
  }
  return consts + i;
}

int size(struct string *s)
{ 
  return s->length;
}

struct string *substring(struct string *s, int first, int n)
{
  if (first < 0 || first + n > s->length) {
    printf("substring([%d],%d,%d) out of range\n", s->length, first, n);
    exit(1);
  }
  if (n == 1) 
    return consts + s->chars[first];
  struct string *t = (struct string *) malloc(sizeof(int) + n);
  if (t == NULL) {
    printf("%s\n", "runtime error: memory allocation failure");
    exit(1);
  }
  int i;
  t->length = n;
  for (i = 0; i < n; i++) 
    t->chars[i] = s->chars[first + i];
  return t;
}

struct string *concat(struct string *a, struct string *b)
{
  if (a->length == 0) 
    return b;
  else if (b->length == 0) 
    return a;
  else {
    int i, n = a->length + b->length;
    struct string *t = (struct string *) malloc(sizeof(int) + n);
    if (t == NULL) {
      printf("%s\n", "runtime error: memory allocation failure");
      exit(1);
    }
    t->length=n;
    for (i = 0; i < a->length; i++)
      t->chars[i] = a->chars[i];
    for (i = 0; i < b->length; i++)
      t->chars[i + a->length] = b->chars[i];
        return t;
  }
}

int not(int i)
{ 
  return !i;
}

/* #undef getchar */

struct string *getch()
{
  int i = getc(stdin);
  if (i == EOF) 
    return &empty;
  else return 
    consts+i;
}
