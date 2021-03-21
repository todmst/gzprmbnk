#!/usr/bin/perl
use strict;
# use warnings;
use feature 'say';
use DBI;
use utf8;
use open qw(:std :utf8);

my $LogPath = 'out';
open(my $fh, '<:encoding(UTF-8)', $LogPath) or die "Could not open file '$LogPath' $!";

my $dbh = DBI->connect("DBI:mysql:gazprombank",'gazprombank','XXXXXXXXXXXXXX');
die "failed to connect to MySQL database:DBI->errstr()" unless($dbh);

while (my $row = <$fh>) {
  # 19 - это длинна строки даты - 2012-02-13 14:39:22
  my ($Date, $IntID, $Flag, $Address, $Info) = ($row =~/^(.{19})\s([^\s]+)\s(?:(<=|=>|->|\*\*|==)\s([^\s]+))?\s?(.*$)/);


  # Откусим время, чтобы получить строку лога (без временной метки)
  my $LogStr = substr $row, 19;

  # Считаем, что за значением  id=xxxx может следовать пробел, конец строки или "
  my ($Id) = ($Info =~ /id=([^\s^"]+)/);# [ \s"]
  if($Flag && ($Flag eq '<=') && $Id){
    $dbh->do("INSERT INTO message(created,id,int_id,str,status,address) VALUES (?,?,?,?,?,?)", undef,
      $Date,
      $Id,
      $IntID,
      $LogStr,
      $Flag,
      $Address,
    );
  } else {
    $dbh->do("INSERT INTO log(created,int_id,str,address) VALUES (?,?,?,?)", undef,
      $Date,
      $IntID,
      $LogStr,
      $Address,
    );
  }
}


=pod
Есть такие моменты:
1. В исходной схеме в таблице message не было поля address, а по этому полю надо искать записи, поэтому добавил его

2. Сделали в message поле status, но не используем его

3. Есть строки c флагом eq '<=' но без значения id=xxxx, пример
2012-02-13 14:40:43 1RwtKt-0008TD-DS <= <> R=1RwtJV-0009RI-O2 U=mailnull P=local S=2306
Значит пишем в message только те строки, где нашлось значение id, раз message.id у нас NOT NULL

4. в значениях address встречаются '<>' и ':blackhole:', импортируем их как есть.
=cut
