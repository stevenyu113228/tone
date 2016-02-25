/*
 * Tone Arduino 自動撥號系統
 * By StevenYu2016/02/25
 * 
 * 參考資料:
 * http://rogue-code.googlecode.com/files/Arduino-Library-Tone.zip
 * http://www.geek-workshop.com/thread-242-1-1.html
*/
#include <Tone.h>
//DTMF定義https://zh.wikipedia.org/wiki/%E5%8F%8C%E9%9F%B3%E5%A4%9A%E9%A2%91
//定義 freq1、freq2 為 Tone 的物件
Tone freq1;
Tone freq2;

//依序宣告 DTMF_freq1 與 DTMF_freq2 陣列
//ex:[0]位置為 撥號數字為 0 時，須輸出的頻率
//自己定義[10] = * ; [11] = #
const int DTMF_freq1[] = {1336, 1209, 1336, 1477, 1209, 1336, 1477, 1209, 1336, 1477, 1209, 1477};
const int DTMF_freq2[] = {941,  697,  697,  697,  770,  770,  770,  852,  852,  852, 941, 941};
/*
   值 低頻 高頻
   0  941 1336
   1  697 1209
   2  697 1336
   3  697 1477
   4  770 1209
   5  770 1336
   6  770 1477
   7  852 1209
   8  852 1336
   9  852 1477
   *  941 1209
   #  941 1477
*/
void setup()
{
  //Serial開啟，鮑率為9600
  Serial.begin(9600);

  //定義產生聲音的腳位為11與12
  //11產生高頻 12產生低頻
  //務必使用Arduino支援PWN的接腳(腳位旁會有~標誌)
  freq1.begin(11);
  freq2.begin(12);

  //將8,9,10腳位設定為輸入腳
  //請各別接上開關
  pinMode(10, INPUT);
  pinMode(9, INPUT);
  pinMode(8, INPUT);
}

void loop()
{
  //透過String宣告需要撥號的號碼，範例如下
  String A_Number = "09123456789";
  String B_Number = "0412345678";
  String C_Number = "#31#**12345";

  //如果開關被觸發
  //執行PlayDTMF函式並 delay 1秒
  //詳情請見下方PlayDTMF註解
  if (digitalRead(10) == 1)
  {
    PlayDTMF(C_Number, 200, 300);
    delay(1000);
  }

  //以下if內容跟上面皆相同，故不贅述
  /* if(digitalRead(9) == 1)
    {
    PlayDTMF(B_Number, 200, 300);
    delay(1000);
    }

    if(digitalRead(8) == 1)
    {
    PlayDTMF(C_Number, 200, 300);
    delay(1000);
    }
  */


  /*
    //如果需要將自動撥號改為手動撥號(透過Serial)
    //請柱姐掉loop內的以上內容，並把以下內容開啟(柱柱姐表示.....)
    //當Serial有輸入值時，把值慢慢丟到Phone_Number
    //避免傳輸誤判之類的問題，每一次的傳輸delay 2ms
    while (Serial.available() > 0)
    {
      Phone_Number += char(Serial.read());
      delay(2);
      boolean mark = 1;
    }

    //傳輸完畢後，執行PlayDTMF函數開始撥號
    PlayDTMF(Phone_Number, 200, 300);

    //如果剛剛撥號過了mark == 1
    //那重新把Phone_Number清空
    //mark(紀錄是否撥過號為0)
    if(mark == 1)
    {
        Phone_Number = "";
        Serial.println();
        mark = 0;
    }
  */
}




/*
   函式PlayDTMF
   PlayDTMF(傳入連續撥號值(String),持續長度(ms),每個按鍵延遲時間(ms)
   貼心小提醒
   1.傳入的String請丟Ascii例如
     String input = "0987654321*##*111";
   2.持續長度建議勿小於200ms、勿小於200ms、勿小於200ms，因為很重要所以要說三次
   3.按鍵延遲時間建議勿小於300ms、勿小於300ms、勿小於300ms，因為很重要所以要說三次
*/
void PlayDTMF(String Number, long duration, long pause)
{

  //如果輸入電話號碼為空，或是延遲長度及按鍵延遲時間<=0，視為誤判
  //直接離開函式
  if (Number.length() == 0 || duration <= 0 || pause <= 0)
  {
    return;
  }

  //開始依序抓出Number陣列(String)每一格的值
  for (int i = 0; i < Number.length(); i++)
  {
    //如果Number[i]是0~9之間
    //之所以可以用大於小於是因為是用Ascii字元儲存的

    if (Number[i] >= '0' && Number[i] <= '9')
    {
      /*
        自動把Number[i]中的Ascii轉int
        因為0的Ascii = 48 (Dec)
        所以1的Ascii = 49
        String儲存數字是用Ascii存的
        所以1讀到49 給它減掉0的值48 就會取得1了
        算是一個很簡單的Ascii轉int方法
      */
      Number[i] -= '0';

      //計算完畢後，把值用十進位方式print出來
      Serial.print(Number[i], DEC);

      //分別輸出低頻與高頻的頻率
      //freq1,2.play函數 各別輸入頻率(hz)以及持續時間duration
      freq1.play(DTMF_freq1[Number[i]], duration);
      freq2.play(DTMF_freq2[Number[i]], duration);
      //delay輸入的按鍵延遲時間
      delay(pause);
    }

    //如果Number[i]的值是#或*(不是數字)
    //不適用上面條件
    else if ( (Number[i] == '#') || (Number[i] == '*'))
    {
      //如果是#的話
      //把"在Serial中print出來
      //分別輸出低頻與高頻的頻率
      //freq1,2.play函數 各別輸入頻率(hz)以及持續時間duration
      //前面有定義DTMF_freqX[11]是#
      if (Number[i] == '#')
      {
        Serial.print("#");
        freq1.play(DTMF_freq1[11], duration);
        freq2.play(DTMF_freq2[11], duration);
        delay(pause);
      }
      //如果是*的話
      //把"在Serial中print出來
      //分別輸出低頻與高頻的頻率
      //freq1,2.play函數 各別輸入頻率(hz)以及持續時間duration
      //前面有定義DTMF_freqX[10]是*
      else if (Number[i] == '*')
      {
        Serial.print("*");
        freq1.play(DTMF_freq1[10], duration);
        freq2.play(DTMF_freq2[10], duration);
        delay(pause);
      }
    }
  }
    //Serial換行
    Serial.print("\n");

}
