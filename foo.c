#include <stdio.h>
#include <stdlib.h>

#pragma optnone

#define false 0
#define true 1
typedef int bool;

#define forin(i,a) for(int i = 0; i < a; i++)

int N=8;
int M=8;
int BANG=3;
int** pole;//[8][8];

void test() {
	int* z = pole[0];
}

void test1(x1) {
	int* z = pole[x1];
}

void test2(x1) {
	int z = x1;
}

void swap(x1,y1,x2,y2) {
	int* z = pole[x1];
	//int k=pole[x1][y1];
	//pole[x1][y1]=pole[x2][y2];
	//pole[x2][y2]=k;
}

int poisk(temp, i, j, x, y) {
	if (temp==pole[i][j] && i+x>=0 && i+x<N && j+y>=0 && j+y<M) {
		return 1+poisk(temp,i+x,j+y,x,y);
	}
	if (temp==pole[i][j]) {
		return 1;
	}
	return 0;
}

bool findLine() {
	int flag=false;
	forin(i,N) {
		forin(j,M) {
			if (poisk(pole[i][j],i,j,0,1)>=BANG || poisk(pole[i][j],i,j,1,0)>=BANG) {
				flag=true;
			}
		}
	}
	return flag;
}

void generate() {
	forin(i,N) {
		forin(j,M) {
			do {
				pole[i][j]=/*ceil*/(random()*7);
			} while(poisk(pole[i][j],i,j,-1,0)>=BANG || poisk(pole[i][j],i,j,0,-1)>=BANG);
		}
	}
	forin(i,N) {
		forin(j,M) {
			int fl=0;
			if (i<N-1) {
				swap(i,j,i+1,j);
				if (findLine()==true) fl=1;
				swap(i,j,i+1,j);
			}
			if (i>0) {
				swap(i,j,i-1,j);
				if (findLine()==true) fl=1;
				swap(i,j,i-1,j);
			}
			if (j<M-1) {
				swap(i,j,i,j+1);
				if (findLine()==true) fl=1;
				swap(i,j,i,j+1);
			}
			if (j>0) {
				swap(i,j,i,j-1);
				if (findLine()==true) fl=1;
				swap(i,j,i,j-1);
			}
			if (fl==1) return;
		}
	}
	generate();
}


int /*__attribute__((optnone))*/ main(int argc, char const *argv[]) {
	pole = malloc(N*sizeof(int)*2); // 64 bit
	forin(i,N) {
		pole[i] = malloc(M*sizeof(int));
	}
	//return 0;
	/*forin(i,N) {
		if(pole[i] == null) pole[i] = [];
	}*/

	generate();

	/*forin(i,N) {
		//var str="";
		forin(j,M) {
			//str=str+pole[i][j]+' ';
		}
		//printf(str);
	}*/

	N = 11;
	M = 8;

	int xxx = 0;
	xxx = N;

	printf("Привет! Hello world Clang\n");
}


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
/*
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
}*/