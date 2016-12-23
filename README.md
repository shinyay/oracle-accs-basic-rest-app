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

#### Maven で作成した Java ソースファイル

**jersey-quickstart-grizzly2** によって Java ソースファイルが2つ作成されています。

- Main.java
- MyResource.java

##### Main.java

ここでは、Grizzly による HttpServer の起動を行っています。

```java
package com.sample.shinyay.rest;

import org.glassfish.grizzly.http.server.HttpServer;
import org.glassfish.jersey.grizzly2.httpserver.GrizzlyHttpServerFactory;
import org.glassfish.jersey.server.ResourceConfig;

import java.io.IOException;
import java.net.URI;

/**
 * Main class.
 *
 */
public class Main {
    // Base URI the Grizzly HTTP server will listen on
    public static final String BASE_URI = "http://localhost:8080/myapp/";

    /**
     * Starts Grizzly HTTP server exposing JAX-RS resources defined in this application.
     * @return Grizzly HTTP server.
     */
    public static HttpServer startServer() {
        // create a resource config that scans for JAX-RS resources and providers
        // in com.sample.shinyay.rest package
        final ResourceConfig rc = new ResourceConfig().packages("com.sample.shinyay.rest");

        // create and start a new instance of grizzly http server
        // exposing the Jersey application at BASE_URI
        return GrizzlyHttpServerFactory.createHttpServer(URI.create(BASE_URI), rc);
    }

    /**
     * Main method.
     * @param args
     * @throws IOException
     */
    public static void main(String[] args) throws IOException {
        final HttpServer server = startServer();
        System.out.println(String.format("Jersey app started with WADL available at "
                + "%sapplication.wadl\nHit enter to stop it...", BASE_URI));
        System.in.read();
        server.stop();
    }
}

```

**BASE_URI** は、REST メソッドを追加する URI を指定しています。
**ResourceConfig** クラスは、アノテーションされる Jersey のクラスが配置されるパッケージを指定します。

##### MyResource.java

**MyResource** クラスは、REST メソッドによる操作を定義しています。このデフォルトの状態では、`http://localhost:8080/myapp/myresource` に対して `GET` でアクセスすると動作します。

```java
package com.sample.shinyay.rest;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

/**
 * Root resource (exposed at "myresource" path)
 */
@Path("myresource")
public class MyResource {

    /**
     * Method handling HTTP GET requests. The returned object will be sent
     * to the client as "text/plain" media type.
     *
     * @return String that will be returned as a text/plain response.
     */
    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String getIt() {
        return "Got it!";
    }
}

```

#### 動作確認

動作確認をしてみます。まず、コンパイルを行います。

```bash
$ mvn clean compile
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building jersey_service 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ jersey_service ---
[INFO] Deleting D:\msys64\home\syanagih\work\git-repo\oracle-accs-basic-rest-app\maven\jersey_service\target
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ jersey_service ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] skip non existing resourceDirectory D:\msys64\home\syanagih\work\git-repo\oracle-accs-basic-rest-app\maven\jersey_service\src\main\resources
[INFO]
[INFO] --- maven-compiler-plugin:2.5.1:compile (default-compile) @ jersey_service ---
[INFO] Compiling 2 source files to D:\msys64\home\syanagih\work\git-repo\oracle-accs-basic-rest-app\maven\jersey_service\target\classes
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.897 s
[INFO] Finished at: 2016-12-24T07:39:37+09:00
[INFO] Final Memory: 15M/212M
[INFO] ------------------------------------------------------------------------
```

次に、Main メソッドを実行して Grizzly を起動します。

```bash
$ mvn exec:java
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building jersey_service 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] >>> exec-maven-plugin:1.2.1:java (default-cli) > validate @ jersey_service >>>
[INFO]
[INFO] <<< exec-maven-plugin:1.2.1:java (default-cli) < validate @ jersey_service <<<
[INFO]
[INFO] --- exec-maven-plugin:1.2.1:java (default-cli) @ jersey_service ---
12 24, 2016 7:41:32 午前 org.glassfish.grizzly.http.server.NetworkListener start
情報: Started listener bound to [localhost:8080]
12 24, 2016 7:41:32 午前 org.glassfish.grizzly.http.server.HttpServer start
情報: [HttpServer] Started.
Jersey app started with WADL available at http://localhost:8080/myapp/application.wadl
Hit enter to stop it...
```

起動したら、REST API のエンドポイントにブラウザからアクセスしてみます。

- http://localhost:8080/myapp/myresource

![](images/accs-rest02.jpg)

正常に動作した事が確認できます。
