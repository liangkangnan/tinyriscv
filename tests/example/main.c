
static void set_test_pass()
{
    asm("li x27, 0x01");
}

static void set_test_fail()
{
    asm("li x27, 0x00");
}

// add 1 to 100
int main()
{
    int i;
    int sum;

    sum = 0;

    for (i = 0; i <= 100; i++)
        sum += i;

    if (sum == 5050)
        set_test_pass();
    else
        set_test_fail();

    return 0;
}
