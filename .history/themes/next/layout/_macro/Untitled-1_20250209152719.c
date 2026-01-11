#include <iostream>
#include <random>
#include <ctime>

using namespace std;

int w1=100,w2=3,t=20000;
int now=45,suipian=6;
long long int sum=0;
int goushi=0,baodi=0;
int i=0,j=0;
int main()
{
    srand( (unsigned int)time( 0 ) );
    for(i=0,j=0; i<100000000 && j<1000; i++)
    {
        int tmp=rand()%20000;
        if(now==49)//50次必出碎片，次数清零
        {
            suipian++;
            now=0;
        }
        if(tmp>100) now++;//没有中1/200的概率，次数+1
//        else if(tmp >= 100 && tmp < 103){
//            cout << i << " " << suipian << endl;
//            j++;
//            sum+=i;
//            i=0;
//            suipian=0;
//            goushi++;
//            continue;
//        }
        else {//中1/200的概率，碎片+1，次数清零
            suipian++;
            now=0;
        }
        if(suipian == 60){
            cout << j+1 << "  " << i << " " << suipian << endl;
            j++;
            sum+=i;
            i=0;
            suipian=0;
            baodi++;
            now=0;
            continue;
        }
    }
    cout << i << " " << j << endl;
    cout << sum/10000 << " " << goushi << " " << baodi << endl;
    return 0;
}
