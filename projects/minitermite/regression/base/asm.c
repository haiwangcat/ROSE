void f() {
}

#if defined(__x86_64__)
unsigned long int swap64(unsigned long int _data)
{
    __asm__ ("bswap   %0" : "+r" (_data));
    return _data;
}
#endif

