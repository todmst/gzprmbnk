#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
use DBI;

use constant {
  MAX_LOG_ROWS       => 100,
  MAX_ADDRESS_LENGTH => 220,
};


my $dbh = DBI->connect("DBI:mysql:gazprombank",'gazprombank','XXXXXXXXXXXXXX');
die "failed to connect to MySQL database:DBI->errstr()" unless($dbh);


helper db => sub { $dbh };

get '/' => sub ($c) {
  $c->render(template => 'log_form');
};


get '/log_by_address' => sub ($c) {
  my $Address = $c->param('address');


  unless ($Address){
    $c->render(template => 'error', error => 'Поле Адрес обязательно для заполнения');
    return;
  }

  if (length($Address) > &MAX_ADDRESS_LENGTH){
    $c->render(template => 'error', error => 'Максимальная длинна адреса должна быть не более ' . &MAX_ADDRESS_LENGTH . ' символов');
    return;
  }

  my $Results = $c->db->selectall_arrayref('
    (SELECT created, str, int_id FROM log
    WHERE address=?)
    UNION
    (SELECT created, str, int_id FROM message
    WHERE address=?)
    ORDER BY int_id, created
    LIMIT ?
    ',{}, $Address, $Address, &MAX_LOG_ROWS+1);
  my $NotAllRows;
  if (scalar @$Results > &MAX_LOG_ROWS ){
    $NotAllRows = 1;
    pop @$Results;
  }

  $c->render(template => 'log_by_address', results => $Results, address => $Address, notallrows => $NotAllRows, max_log_rows => &MAX_LOG_ROWS);
};

app->start;

__DATA__

@@ log_form.html.ep
<html>
<body>
<H1>Запрос записей лога по адресу получателя</H1>
<form action="/log_by_address">
  <label for="fname">Адрес получателя:</label>
  <input type="text" id="address" name="address"><br><br>
  <input type="submit" value="Отправить">
</form>

</body>
</html>



@@ log_by_address.html.ep
<html>
<head>
<style>
table {
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

td, th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}

tr:nth-child(even) {
  background-color: #dddddd;
}
</style>
</head>
<body>
<div><a href="/">Home</a><div>
<h2>Записи лога по адресу <%= $address %></h2>

<table>
  <tr>
    <th>timestamp</th>
    <th>Строка лога</th>
  </tr>
   % for my $row (@$results) {
   <tr>
      <td><%= $row->[0] %></td>
      <td><%= $row->[1] %></td>
   </tr>
   % }
</table>

% if ($notallrows) {
  <span style="color: red; font-size: 2em">Выведены только первые <%= $max_log_rows %> записей лога!</span>
% }

</body>
</html>


@@ error.html.ep
<body>
<div><a href="/">Home</a><div>
<span style="color: red; font-size: 2em"><%= $error %></span>
</body>
</html>
