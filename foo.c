#include <stdio.h>
#include <stdlib.h>

/*

static double f(double x, void *params)
{
    //struct parameters p = (struct parameters *);// params;
    struct parameters *p = *{ 1, 2 };
    double a = p->a, b = b->b;
    return some_expression_involving(a,b,x);
}

double stuff(double a, double b)
{
    struct parameters par = { a, b };
    return integrate(f, &par);
}*/

struct parameters
{
    double a, b;
};

int func(int a)
{
	return a + 4;
}

int main(int argc, char const *argv[])
{
	/* code */
	printf("Привет! Hello world Clang\n");

	struct parameters *p = malloc (sizeof (struct parameters));

	//const int local_function = [&](int parameter) {
	//  // Do something
	//};
	//void *a = local_function;
	//a(1);

	//int c = 6;
	//int b = 4;
//
	//return func(func(b)+c);
}