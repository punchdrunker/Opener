## About
windowsでコピペしたネットワークサーバのファイルパス(\\\\foo-server\bar\fizz\buzzのようなパス)をmacで開く為のアプリケーションです。
sambaで自動マウントする機能だけあるので、sambaを利用して接続する場合は、ディスクをマウントする必要はありません。
Windowsでネットワークドライブとして割り当てられた状態のパス(Z:\\dir1\dir2 など)は対応していません。ホスト名から始まるパスにしか対応していません。


## Quick start

1. <https://sourceforge.net/projects/opener/files/>からzipファイルをダウンロードして展開

2. 展開したOpener.appをダブルクリックで起動(アプリケーションフォルダに移動などは適宜)

3. 入力フィールドにファイルパスを貼って、ボタンを押すと、Finderで指定のファイル/ディレクトリが開きます

## Todo

Windowsでネットワークドライブとして割り当てられた状態のパスをどうするか考えるかもしれない。。。

## License
BSD-LICENSED
Copyright (c) 2011, punchdrunker.org
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

Neither the name of the punchdrunker.org nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
