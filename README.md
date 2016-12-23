# Oracle Application Container Cloud Service - Jersey & Grizzly を用いた REST アプリケーション
---
## 説明

Java EE アプリケーションサーバを利用せず、軽量な Grizzly Web サーバと、Jersey REST フレームワークを使用して RESTful アプリケーションを開発します。

#### **Grizzly Web サーバ**

[Project Grizzly](https://grizzly.java.net/) とは、NIO API を使用したピュア Java Web サーバ・エンジンです。主な用途は、GlassFish アプリケーションサーバの Web サーバ・コンポーネントとして利用されています。

![](https://grizzly.java.net/images/stack.png)

#### **Jersey, REST, and JAX-RS**

Jersey とは、RESTful アプリケーションを開発に利用されるオープンソースのフレームワークです。Jersey は、JAX-RS API をサポートしており、また JAX-RS 参照実装となっています。

REST はスケーラブルな Web サービスを開発すると際のソフトウェア・アーキテクチャ・スタイルです。REST は、SOAP や WSDL による Web サービスよりもシンプルです。RESTful Web サービスですは、HTTP 経由で通信し、Webブラウザ同様に HTTP のメソッド(GET, POST, PUT, DELETE など) を使用してリモートサーバと通信します。

## 作成するアプリケーション
LIST に格納さえれているデータに対して、2種類のメソッドを作成します。

1. LIST 内の全てのデータを返す
2. ID によりデータを特定する

データは平文テキストデータとして扱います。

## 前提

- [Maven 3.3.1 以上](https://maven.apache.org/)
- [Java SE 8u45 以降](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
- 統合開発環境 (EWclipse, NetBeans, など)
- [cURL](http://curl.haxx.se/)

## 手順

### Maven プロジェクトの作成

**Jersey** と **Grizzly** を用いたアプリケーションを作成する時に、雛形の用意には **Maven** を使用します。

次のコマンド・オプションを用いて Maven を実行します:

```bash
mvn archetype:generate -DarchetypeGroupId=org.glassfish.jersey.archetypes -DarchetypeArtifactId=jersey-quickstart-grizzly2 -DarchetypeVersion=2.25 -DinteractiveMode=false -DgroupId=com.sample.shinyay.rest -DartifactId=jersey_service -Dpackage=com.sample.shinyay.rest -DarchetypeVersion=2.25
```
#### Maven で作成したプロジェクトのディレクトリ構造

mvn コマンドにより作成されるディレクトリ構造は次のようになります:

![](./images/accs-rest01.jpg)


#### Maven で作成した pom.xml

また、 生成された **pom.xml** を確認します。

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <groupId>com.sample.shinyay.rest</groupId>
    <artifactId>jersey_service</artifactId>
    <packaging>jar</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>jersey_service</name>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.glassfish.jersey</groupId>
                <artifactId>jersey-bom</artifactId>
                <version>${jersey.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <dependencies>
        <dependency>
            <groupId>org.glassfish.jersey.containers</groupId>
            <artifactId>jersey-container-grizzly2-http</artifactId>
        </dependency>
        <!-- uncomment this to get JSON support:
         <dependency>
            <groupId>org.glassfish.jersey.media</groupId>
            <artifactId>jersey-media-moxy</artifactId>
        </dependency>
        -->
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.9</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>2.5.1</version>
                <inherited>true</inherited>
                <configuration>
                    <source>1.7</source>
                    <target>1.7</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>exec-maven-plugin</artifactId>
                <version>1.2.1</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>java</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <mainClass>com.sample.shinyay.rest.Main</mainClass>
                </configuration>
            </plugin>
        </plugins>
    </build>

    <properties>
        <jersey.version>2.25</jersey.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
</project>
```

**dependencyManagement** 要素によって、REST に関する **jersey** 関連の依存ライブラリのバージョンを定義しています。

- [参考: POM Reference / Dependency Management](https://maven.apache.org/pom.html#Dependency_Management)

**dependencyManagement** で Jersesy の使用が管理されているので、**dependency** 要素で定義を行っている ***jersey-container-grizzly2-http*** では、使用バージョンに関する定義は行っていません。

また、ビルド・プラグインとして定義されている **maven-compiler-plugin** では、使用する Java のバージョンが ***1.7*** になっています。これを、***1.8*** に変更します。
