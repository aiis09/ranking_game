import processing.sound.*;
import java.io.BufferedWriter;
import java.util.Collections;
import java.util.Comparator;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

String filename = "ranks.txt";//ファイルの読み込みに使うパス
ArrayList<String> tmpRanks = new ArrayList<String>();//ファイルから読み込んだ3種類の文字列を分けて入れておくためのArrayList
ArrayList<String> tmpScores = new ArrayList<String>();
ArrayList<String> tmpNames = new ArrayList<String>();
boolean rankingScene = false;

SoundFile sound1, sound2;
PImage picture1;
int scene = 1;//1スタート画面, 2プレイ画面, 3クリア画面, 4ランキング画面
int revel = 1;//1簡単, 2普通, 3難しい
int trick = 1;//1餌食べ練習, 2餌食べ, 3運ゲー
//trick 1,2 餌食べゲーム
int squid_x = 240;//イカの位置
int squid_y = 240;//イカの位置
int eat_x = 0;//イカの速度
int eat_y = 0;//イカの速度
int eye_x1 = 4;//イカの目の位置
int eye_x2 = 4;//イカの目の位置
int eye_y1 = 6;//イカの目の位置
int eye_y2 = 6;//イカの目の位置
int rnd_x, rnd_y;//ランダムな餌の位置
int yellow_rndx, yellow_rndy;//ランダムな加点の餌の位置
int eat_start = 1000000;//millisの基準点
int eat_current = 1000000;//現在の秒数
int eat_score = 0;//スコア
boolean yellow_click = false;
boolean eat_clear = false;
//trick = 3 運ゲー
int random_scene = 1;//1選ぶ 2結果
int random_score = 0;//5点満点のスコア
int random_start = 1000000;//millisの基準点
int random_current = 1000000;//現在の秒数
int random_num1 = int(random(5, 10));//ランダムな得点
int random_num2 = int(random(5, 10));
int random_num3 = int(random(5, 10));
int clickColor0, clickColor1, clickColor2, select;//どこをクリックしたか
boolean clickSquare = false;

int count = 0;
int tmpcount = 0;
int score = 0;
String newRank, newName, newScore;
String name = "なめこ";

//----------------------------------------- Rankerクラス ---------------------------------------------------
class Ranker {
  String rank, name, score;
  Ranker(String rank, String name, String score) {
    this.rank = rank;
    this.name = name;
    this.score = score;
  }
  void displayRanks() {
    //fill(255);
    //rect(width/2, 130*(ranks.indexOf(this)+1), 500, 50);
    fill(0); //文字の色は黒
    text(rank+". "+name, 140, 30+100*(ranks.indexOf(this)));
    text("                           "+score+"点", 140, 30+100*(ranks.indexOf(this)));
  }
}
//----------------------------------------- Rankerクラス ---------------------------------------------------

Ranker ranker;
ArrayList<Ranker> ranks = new ArrayList<Ranker>();

//-----------------------------------------同じ種類の文字列に分類する----------------------------------------------------------
void classify(String[] lines) {
  tmpRanks = new ArrayList<String>();
  tmpNames = new ArrayList<String>();
  tmpScores = new ArrayList<String>();
  for (int i=0; i<lines.length; i++) {
    String[] words = lines[i].split(", "); //行からrank, name, scoreを「, 」を境に分ける
    tmpRanks.add(words[0]); //要素がrankだけのArrayListに入れる
    tmpNames.add(words[1]);  //要素がnameだけのArrayListに入れる
    tmpScores.add(words[2]); //要素がscoreだけのArrayListに入れる
  }
}
//-----------------------------------------同じ種類の文字列に分類する----------------------------------------------------------


//-----------------------------------------ランキング画面を表示する関数----------------------------------------------------------
void setRankingScene() {
  //background(0);
  count++;
  scene = 4;
  newRank = String.valueOf(ranks.size()+1); //順位はひとまず最下位にしておく
  newName = String.valueOf(name);
  newScore = String.valueOf(score);
}
//-----------------------------------------ランキング画面を表示する関数----------------------------------------------------------

void imageCenteredAt(PImage image, float x, float y, float offset, float scale) {
  image(image, x - image.width * scale / 2 - offset, y - image.height * scale / 2 - offset, image.width * scale, image.height * scale);
}

void settings() {
  size(480, 480);
}

void setup() {
  background(255, 255, 255);
  PFont font = createFont("YuGothic", 32);
  textFont(font);
  rectMode(CENTER);
  picture1 = loadImage("start.png");
  sound1 = new SoundFile(this, "pon.mp3");
  sound2 = new SoundFile(this, "eat.mp3");
}

void draw() {
  background(255, 255, 255);
  if (scene == 1) {
    //スタート画面
    background(255, 255, 255);
    imageCenteredAt(picture1, 240, 220, 0, 0.45);
    noStroke();
    fill(100, 200, 255);
    rect(140, 325, 80, 50);//左
    rect(240, 325, 80, 50);//真ん中
    rect(340, 325, 80, 50);//右
    textFont(createFont("Helvetica",50, true));
    fill(0, 0, 0);
    text(name, 20, 180);
    textFont(createFont("Helvetica", 17, true));
    text("かんたん", 110, 330);
    text("ふつう", 215, 330);
    text("難しい", 310, 330);
  } else if (scene == 2) {
    if (trick == 1) {//餌の練習
      if (revel == 1) {
        eatGame(true, 3);
      } else if (revel == 2) {
        eatGame(true, 3);
      } else if (revel == 3) {
        eatGame(true, 2);
      }
    } else if (trick == 2) {
      if (revel == 1) {
        eatGame(false, 3);
      } else if (revel == 2) {
        eatGame(false, 3);
      } else if (revel == 3) {
        eatGame(false, 2);
      }
    } else if (trick == 3) {
      if (random_scene == 1) {
        background(255, 255, 255);
        noStroke();
        background(255, 255, 255);
        textFont(createFont("Helvetica", 30, true));
        text("先ほどの点数" + eat_score + "点！", 100, 50);
        text("どれかクリックせよ！", 100, 100);
        fill(255, 0, 0);
        text("ボーナスチャンス！！！", 100, 400);
        text(random_num1, 100, 260);
        text(random_num2, 220, 260);
        text(random_num3, 340, 260);
        if (!clickSquare) {
          fill(0, 0, 0);
          square(120, 240, 60);
          square(240, 240, 60);
          square(360, 240, 60);
        } else if (clickSquare && millis() - random_start < 3000) {
          fill(clickColor0, 0, 0);
          square(120, 240, 60);
          fill(clickColor1, 0, 0);
          square(240, 240, 60);
          fill(clickColor2, 0, 0);
          square(360, 240, 60);
          fill(0, 0, 0);
          textFont(createFont("Helvetica", 30, true));
          text(3 - (millis() - random_start) / 1000, 230, 150);
        } else if (millis() - random_start >= 3000) {
          random_scene = 2;
        }
      } else if (random_scene == 2) {
        //ゲームオーバー画面
        background(255, 255, 255);
        text("！！！！結果！！！！", 100, 100);
        if (select == 0) {
          fill(255, 0, 0);
          text(random_num1, 100, 260);
          fill(0, 0, 0);
          text(random_num2, 220, 260);
          text(random_num3, 340, 260);
        } else if (select == 1) {
          fill(255, 0, 0);
          text(random_num2, 220, 260);
          fill(0, 0, 0);
          text(random_num1, 100, 260);
          text(random_num3, 340, 260);
        } else if (select == 2) {
          fill(255, 0, 0);
          text(random_num3, 340, 260);
          fill(0, 0, 0);
          text(random_num1, 100, 260);
          text(random_num2, 220, 260);
        }
      }
    }
  } else if (scene == 3) {
    background(255, 255, 255);
    textFont(createFont("Helvetica", 30, true));
    fill(0, 0, 0);
    text("１つ目のゲームの得点　" + eat_score + "点", 50, 100);
    text("２つ目のゲームの得点　" + random_score + "点", 50, 180);
    text("　　　　　　合計得点　" + score + "点", 50, 260);
  } else if (scene == 4) {
    if (count!=tmpcount) { //前フレームのcountと今のフレームのcountが違っていたら
      String[] lines = loadStrings(filename);
      tmpcount = count;
      classify(lines); //同じ種類の文字列に分類する

      ranks = new ArrayList<Ranker>();
      for (int i=0; i<lines.length; i++) {
        ranks.add(new Ranker(tmpRanks.get(i), tmpNames.get(i), tmpScores.get(i)));  //tmpRanksは順位を、tmpNamesは名前を、tmpScoresはランクをまとめたArrayListスコア
      }
      ranks.add(new Ranker(newRank, newName, newScore));

      //並べ替える前
      System.out.println("▼並べ替える前");
      for (int i=0; i<ranks.size(); i++) {
        print(ranks.get(i).name);
        System.out.print(" "); //見やすくするためにスペースを空ける
      }
      println("");//改行

      //インスタンスが持つ変数scoreを使ってranksを並べ替える
      Comparator<Ranker> comparator = new Comparator<Ranker>() {
        @Override
          public int compare(Ranker O1, Ranker O2) {
          Integer o1 = Integer.parseInt(O1.score);    //Integer.parseInt(String型の変数)　でString型からint型に変換できる
          Integer o2 = Integer.parseInt(O2.score);
          Integer judgement = Integer.valueOf(o1).compareTo(Integer.valueOf(o2));  //o1とo2を比較して同じなら0、o1の方が小さければ-1、大きければ1
          return -judgement; //降順にする。照準なら「-」を外したjudgement
        }
      };
      Collections.sort(ranks, comparator); //sortメソッドの第2引数に並べ替え方を渡す
      //並べ替えた後
      System.out.println("▼並べ替えた後");
      for (int i=0; i<ranks.size(); i++) {
        print(ranks.get(i).name);
        System.out.print(" "); //見やすくするためにスペースを空ける
      }


      //変数rankを更新する
      for (int i=0; i<ranks.size(); i++) {
        ranks.get(i).rank = i+1+"";  //文字列として入れる
      }
    }

    for (int i=0; i<ranks.size(); i++) {
      ranks.get(i).displayRanks();
    }
  }
}

void mousePressed() {
  if (scene == 1) {
    if (mouseX >= 200 && mouseX < 280 && mouseY >= 300 && mouseY < 350) {//真ん中
      scene = 2;
      //初期化
      revel = 2;
      trick = 1;
      frameRate(200);
      squid_x = 240;
      squid_y = 240;
      eat_x = 0;
      eat_y = 0;
      eye_x1 = 4;
      eye_x2 = 4;
      eye_y1 = 6;
      eye_y2 = 6;
      rnd_x = int(random(20, 460));
      rnd_y = int(random(20, 460));
      eat_start = millis();
    } else if (mouseX >= 100 && mouseX < 180 && mouseY >= 300 && mouseY < 350) {//左
      scene = 2;
      //初期化
      revel = 1;
      trick = 1;
      frameRate(200);
      squid_x = 240;
      squid_y = 240;
      eat_x = 0;
      eat_y = 0;
      eye_x1 = 4;
      eye_x2 = 4;
      eye_y1 = 6;
      eye_y2 = 6;
      rnd_x = int(random(20, 460));
      rnd_y = int(random(20, 460));
      eat_start = millis();
    } else if (mouseX >= 300 && mouseX < 380 && mouseY >= 300 && mouseY < 350) {//右
      scene = 2;
      //初期化
      revel = 3;
      trick = 1;
      frameRate(200);
      squid_x = 240;
      squid_y = 240;
      eat_x = 0;
      eat_y = 0;
      eye_x1 = 4;
      eye_x2 = 4;
      eye_y1 = 6;
      eye_y2 = 6;
      rnd_x = int(random(20, 460));
      rnd_y = int(random(20, 460));
      eat_start = millis();
    }
  } else if (scene == 2 && trick == 3 && random_scene == 1) {
    //square(90, 210, 60)の中、クリック位置が左の四角
    if (mouseX >= 90 && mouseX < 150 && mouseY >= 210 && mouseY < 270) {
      random_start = millis();
      clickSquare = true;
      clickColor0 = 255;
      select = 0;
      random_score = random_num1;
      //square(210, 210, 60)の中、クリック位置が左の四角
    } else if (mouseX >= 210 && mouseX < 270 && mouseY >= 210 && mouseY < 270) {
      random_start = millis();
      clickSquare = true;
      clickColor1 = 255;
      select = 1;
      random_score = random_num2;
      //square(330, 210, 60)の中、クリック位置が左の四角
    } else if (mouseX >= 330 && mouseX < 390 && mouseY >= 210 && mouseY < 270) {
      random_start = millis();
      clickSquare = true;
      clickColor2 = 255;
      select = 2;
      random_score = random_num3;
    }
  }
}

void keyPressed() {
  if (scene == 2) {
    if (trick == 1 || trick == 2) {
      if (trick == 1 && key==ENTER) {
        trick = 2;
        //初期化
        squid_x = 240;
        squid_y = 240;
        eat_x = 0;
        eat_y = 0;
        eye_x1 = 4;
        eye_x2 = 4;
        eye_y1 = 6;
        eye_y2 = 6;
        rnd_x = int(random(20, 460));
        rnd_y = int(random(20, 460));
        eat_start = millis();
      }
      if (keyCode == UP) {
        println("上");
        eat_x = 0;
        eat_y = -1;
        eye_x1 = 4;
        eye_x2 = 4;
        eye_y1 = 7;
        eye_y2 = 7;
      } else if (keyCode == DOWN) {
        println("下");
        eat_x = 0;
        eat_y = 1;
        eye_x1 = 4;
        eye_x2 = 4;
        eye_y1 = 3;
        eye_y2 = 3;
      } else if (keyCode == LEFT) {
        println("左");
        eat_x = -1;
        eat_y = 0;
        eye_x1 = 5;
        eye_x2 = 3;
        eye_y1 = 6;
        eye_y2 = 6;
      } else if (keyCode == RIGHT) {
        println("右");
        eat_x = 1;
        eat_y = 0;
        eye_x1 = 3;
        eye_x2 = 5;
        eye_y1 = 6;
        eye_y2 = 6;
      }
    } else if (trick == 3 && random_scene == 2 && key==ENTER) {
      scene = 3;
      trick = 0;
      random_scene = 0;
      score = eat_score + random_score;
    }
  } else if (scene == 3) {
    if (key==ENTER) {
      setRankingScene();
    }
  } else if (scene == 4) {
    if (keyCode==UP) {//↑キーが押されたらランキング情報をranks.txtに書き出す
      try {
        FileWriter output = new FileWriter("/Users/aiis/Documents/入門プログラミング/その後/Ranking/ranks.txt");//引数には、ファイル名や相対パスではなく、絶対パスを渡します
        PrintWriter pw = new PrintWriter(new BufferedWriter(output));
        StringBuilder buff = new StringBuilder();
        for (int i=0; i<ranks.size(); i++) {
          buff.append(ranks.get(i).rank+", "+ranks.get(i).name+", "+ranks.get(i).score);
          if (i<ranks.size()-1) {
            buff.append("\n");
          }
        }
        String saves = buff.toString();
        println(saves);
        pw.print(saves);
        pw.close();
      }
      catch (IOException e) {
        e.printStackTrace();
      }
    }
  }
}

//-----------------------------------------いかを描画する----------------------------------------------------------
void squid() {
  noStroke();
  fill(squid_x/2, squid_y/2, squid_x + squid_y/2);
  ellipse(squid_x, squid_y, 20, 30);
  quad(squid_x - 15, squid_y - 10, squid_x, squid_y - 25, squid_x + 15, squid_y - 10, squid_x, squid_y + 5);
  ellipse(squid_x - 8, squid_y + 12, 4, 20);
  ellipse(squid_x - 3, squid_y + 12, 4, 20);
  ellipse(squid_x + 3, squid_y + 12, 4, 20);
  ellipse(squid_x + 8, squid_y + 12, 4, 20);
  fill(255, 255, 255);
  ellipse(squid_x - 4, squid_y - 5, 10, 12);
  ellipse(squid_x + 4, squid_y - 5, 10, 12);
  fill(0, 0, 0);
  ellipse(squid_x - eye_x1, squid_y - eye_y1, 5, 5);
  ellipse(squid_x + eye_x2, squid_y - eye_y2, 5, 5);
}
//-----------------------------------------いかを描画する----------------------------------------------------------

//-----------------------------------------餌食べゲーム(練習ver.と本番ver.)----------------------------------------------------------
void eatGame(boolean practice, int scale) {
  if (practice) {
    textFont(createFont("Helvetica",200, true));
    fill(220, 220, 220);
    text("練習", 50, 200);
    text(10 - int(float(eat_current) / 1000) + "秒", 100, 400);
    eat_current = millis() - eat_start;
    textFont(createFont("Helvetica", 17, true));
    fill(0, 0, 0);
    text(int(float(eat_current) / 1000) + "秒 / 10秒", 400, 50);
  } else {  
    eat_current = millis() - eat_start;
    textFont(createFont("Helvetica",200, true));
    fill(220, 220, 220);
    text(eat_score + "点", 50, 200);
    text(30 - int(float(eat_current) / 1000) + "秒", 100, 400);
    textFont(createFont("Helvetica", 17, true));
    fill(0, 0, 0);
    text(int(float(eat_current) / 1000) + "秒 / 30秒", 400, 50);
  }
  textFont(createFont("Helvetica", 17, true));
  fill(0, 0, 0);
  text("餌に向かって重なり食べろ！", 10, 30);
  text("やじるしキーで動きます", 10, 50);
  fill(255, 100, 100);
  circle(rnd_x, rnd_y, 20 * scale);
  squid_x = squid_x + eat_x;
  squid_y = squid_y + eat_y;
  squid();
  //端に行ったら跳ね返るイカ
  if (squid_x >= 480) {
    eat_x = -eat_x;
  } else if (squid_y <= 0) {
    eat_y = -eat_y;
  } else if (squid_x <= 0) {
    eat_x = -eat_x;
  } else if (squid_y >= 480) {
    eat_y = -eat_y;
  }
  //rect(random_x - 20, random_y - 20, 40, 40)の中、rect(230, 220, 20, 40)がえさの位置
  if (squid_x - 10 >= rnd_x - 20 * scale && squid_x + 10 < rnd_x + 20 * scale && squid_y - 10 >= rnd_y - 20 * scale && squid_y + 10 < rnd_y + 20 * scale) {
    println("触れた！");
    rnd_x = int(random(20, 460));
    rnd_y = int(random(20, 460));
    sound2.play();
    if (!practice) {
      if (revel == 1) {
        eat_score = eat_score + 2;
      } else eat_score = eat_score + 1;
    }
  }
  if (practice && eat_current >= 10000) {
    trick = 2;
    //初期化
    eat_current = 1000000;//現在の秒数
    squid_x = 240;
    squid_y = 240;
    eat_x = 0;
    eat_y = 0;
    eye_x1 = 4;
    eye_x2 = 4;
    eye_y1 = 6;
    eye_y2 = 6;
    rnd_x = int(random(20, 460));
    rnd_y = int(random(20, 460));
    eat_start = millis();
  }
  if (!practice && eat_current >= 30000) {
    trick = 3;
    random_start = millis();
    random_score = 0;//スコア
  }
}
//-----------------------------------------餌食べゲーム(練習ver.と本番ver.)----------------------------------------------------------
