# Docker-comainu
Docker image for [Comainu](http://comainu.org/) based on Debian stretch.

## Pull

*Warning:* This image is very large (> 3GB).

```
docker pull sugi/comainu
```

## Image structure

 * `comainu` wrapper script for `script/comainu.pl` is provided. You can run on any directory.
 * Comainu is installed into `/opt/Comainu`.
 * Default entrypoint is bash with `comainu` user (uid: 1000).

## Usage Example

### Interactive

```
docker run --rm -it sugi/comainu
comainu@d85a76989280:/$ comainu plain2longout < /opt/Comainu/sample/plain/sample2.txt
B	最近	サイキン	サイキン	最近	名詞-普通名詞-副詞可能			名詞-普通名詞-一般	*	*	サイキン	最近	最近
	は	ワ	ハ	は	助詞-係助詞			助詞-係助詞	*	*	ハ	は	は
	人工	ジンコー	ジンコウ	人工	名詞-普通名詞-一般			名詞-普通名詞-一般	*	*	ジンコウチノウブンヤ	人工知能分野	人工知能分野
	知能	チノー	チノウ	知能	名詞-普通名詞-一般			*	*	*	*	*	*
	分野	ブンヤ	ブンヤ	分野	名詞-普通名詞-一般			*	*	*	*	*	*
	の	ノ	ノ	の	助詞-格助詞			助詞-格助詞	*	*	ノ	の	の
	話題	ワダイ	ワダイ	話題	名詞-普通名詞-一般			名詞-普通名詞-一般	*	*	ワダイ	話題	話題
	に	ニ	ニ	に	助詞-格助詞			助詞-格助詞	*	*	ニ	に	に
	事欠か	コトカカ	コトカク	事欠く	動詞-一般	五段-カ行	未然形-一般	動詞-一般	五段-カ行	未然形-一般	コトカク	
...
```

### Batch

```
sugi@tempest:~% echo '長単位を自動構成するツールです。' | docker run -i --rm sugi/comainu comainu plain2longout

Finish.
B	長	チョー	チョウ	長	接頭辞			名詞-普通名詞-一般	*	*	チョウタンイ	長単位	長単位
	単位	タンイ	タンイ	単位	名詞-普通名詞-一般			*	*	*	*	*	*
	を	オ	ヲ	を	助詞-格助詞			助詞-格助詞	*	*	ヲ	を	を
	自動	ジドー	ジドウ	自動	名詞-普通名詞-一般			動詞-一般	サ行変格	連体形-一般	ジドウコウセイスル	自動構成する	自動構成する
	構成	コーセー	コウセイ	構成	名詞-普通名詞-サ変可能			*	*	*	*	*	*
	する	スル	スル	為る	動詞-非自立可能	サ行変格	連体形-一般	*	*	*	*	*	*
	ツール	ツール	ツール	ツール-tool	名詞-普通名詞-一般			名詞-普通名詞-一般	*	*	ツール	ツール	ツール
	です	デス	デス	です	助動詞	助動詞-デス	終止形-一般	助動詞	助動詞-デス	終止形-一般	デス	です	です
	。			。	補助記号-句点			補助記号-句点	*	*		。	。
EOS
```
