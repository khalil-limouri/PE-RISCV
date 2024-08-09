//Basic block examples
//Date: 02/03/2021

//Add function
int add (int a, int b)
{	
  return (a+b) ;
}

//Sub function
int sub (int a, int b)
{
  return (a-b) ;
}

//Main
int main()
{

//Initialisation
  int a=0;
  int b=1;
  int c=2;
  int d=3;
  int e=4;
  int f=5;

//Add function call //JAL + ret instructions
  c=add(d,e);
  	
//Simple assignments 
  a=b+c;
  b=a+6;
  c=c+3;
  e=c+f;
  d=c+e;
  a=b+1;
  e=d+5;
  f=e+2;

//Sub function call //JAL + ret instructions
  c=sub(f,e);

  e=e-1;
  a=3;
  b=a+e;
  f=f+1;
  e=f;

//If conditions

  if (c<d)
    {
    //Sub function call //JAL + ret instructions
      c=sub(f,1);
      e=c+1;
      d=c+e;
      d=d+4;
    }
  else
    {
      a=a+c;
      b=d+12;
      e=d+1;
      f=e+2;
    }

  return 0;
}
