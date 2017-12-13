#!C:\Perl64\bin\perl.exe

  use CGI;
 	use strict;
  	use warnings;
  	use DBI;
  	use Data::Dumper;
    use JSON;
    use CGI::Carp qw(warningsToBrowser fatalsToBrowser);


    use constant APP_URL => "http://localhost:81/assignment/index.html";

    print CGI::header();

    my $request = CGI->new;

      #get user's parameter to the variable
    	my $date = $request->param("date");
    	my $time = $request->param("time");
    	my $description = $request->param("description");
      
    	my $search = $request->param("search");

      #if the request is not for search make it blank rather than null 
    	if(not defined $search){
    	    $search = "";
    	}


      #Conditionally executed block
      # if there are form inputs then execute insert and redirect, else return JSON based on select statement
    	if(defined $date and defined $time and defined $description){
            my $db = Database_Connection();
               $db->do('CREATE TABLE IF NOT EXISTS appointments (id INTEGER PRIMARY KEY ,date TEXT, time TEXT, description TEXT NOT NULL)');

            my $sql = 'insert into appointments (date, time, description) values (?, ?, ?)';
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute(
               $date,
               $time,
               $description
            ) or die $sth->errstr;

            $db->disconnect;

             # Redirect to home page
             print "<META HTTP-EQUIV=refresh CONTENT=\"0;URL=".APP_URL."\">\n";

    	}else{
            my $db = Database_Connection();
               $db->do('CREATE TABLE IF NOT EXISTS appointments (id INTEGER PRIMARY KEY ,date TEXT, time TEXT, description TEXT NOT NULL)');
            my $sql = "select date, time, description from appointments WHERE description LIKE '%$search%' order by date desc;";
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute or die $sth->errstr;

           my @jsonString;

             while (my $row = $sth->fetchrow_hashref) {
                push @jsonString, $row;
             }
             $db->disconnect;

             #JSON string
             print to_json(\@jsonString);
    	}

#database connection
  	sub Database_Connection {
          my $dbh = DBI->connect("dbi:SQLite:dbname=DatabaseFile.db") or
          die $DBI::errstr;
          return $dbh;
        }
