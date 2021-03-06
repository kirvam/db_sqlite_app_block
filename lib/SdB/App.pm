package SdB::App;
use Dancer2;

our $VERSION = '0.1';

get '/DANCER' => sub {
    template 'index' => { 'title' => 'SdB::App' };
};

###
use Dancer2; 
use DBI;
use File::Spec;
use File::Slurper qw/ read_text /;
use Template;
use Data::Dumper;
###
my $date = create_date();
my $dbFlag = "DB_CREATED_FILE.txt";
my $database = testForFile($dbFlag);
###
my %hash;
my @AoA = ();
my @array;
my $key;
my $line;
my $ii = 1;
#my $actions = {
#               'none' => sub { my $key = "1"; $hash{ $array[4] }{$key} = [ @array ]; },
#               $hash{ $array[0] } => sub { my $key = create_entry_time(); $key = $key+$ii; $hash{ $array[0] }{$key} = [ @array ]; },
#               '_DEFAULT_' => sub { die "Unrecognized token '$_[0]'; aborting\n" }
#
#};
###
#set 'database'     => File::Spec->catfile(File::Spec->tmpdir(), 'dancr.db');
set 'database'     => File::Spec->catfile(File::Spec->tmpdir(), $database);
set 'session'      => 'Simple';
set 'template'     => 'template_toolkit';
set 'logger'       => 'console';
set 'log'          => 'debug';
set 'show_errors'  => 1;
set 'startup_info' => 1;
set 'warnings'     => 1;
set 'username'     => 'admin';
set 'password'     => 'password';
set 'layout'       => 'main';

my $flash;

sub set_flash {
    my $message = shift;

    $flash = $message;
}

sub get_flash {
    my $msg = $flash;
    $flash = "";
    return $msg;
}

sub connect_db {
    my $dbh = DBI->connect("dbi:SQLite:dbname=".setting('database')) or
        die $DBI::errstr;
    return $dbh;
}

sub init_db {
    my $db = connect_db();
    my $schema = read_text('./schema.sql');
    $db->do($schema) or die $db->errstr;
}

hook before_template_render => sub {
    my $tokens = shift;
    $tokens->{'css_url'} = request->base . 'css/style_1x.css';
    $tokens->{'login_url'} = uri_for('/login');
    $tokens->{'logout_url'} = uri_for('/logout');
};

get '/' => sub {
    my $db = connect_db();
    #my $sql = 'select id, parent, entryDate, category, title, text, status from entries order by id desc';
    my $sql = 'select id, parent, entryDate, title, entryDate,text, status from entries order by title desc';
    #my $sql = 'select id, parent, entryDate, title, text, status from entries where id in (\'1\',\'2\',\'17\') order by id desc';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;
   
    my $stha = $db->prepare($sql) or die $db->errstr;
    $stha->execute or die $sth->errstr;
 
    ###print "$sth->fetchall_hashref()\n\n";
    my $entries = $sth->fetchall_hashref('id');
    
    my $list = $stha->fetchall_arrayref();
    my $spectab = "<p><table><tr><td>dog</td><td>bat</td><td>cow</td></tr></table><p>\n";
    my $data = $entries;
     ###print Dumper $data;
     print Dumper \$list;
     print "Finished with dumping \$list.\n";
     ###
my $html = q{};
my @AoA = ();
@AoA = @{ $list };
print Dumper \@AoA;
print "Finished Dumper \@AoA\n";
for_while_loop_2(@AoA);
#print "Dumper \%hash \n";
#print Dumper \%hash;
$html = style_ref_HoHoA_1_print_FH(\%hash,$html);
print "Dumper \%hash \n";
print Dumper \%hash;
print Dumper \$html;
     ###
    template 'show_entries.tt', {
        'msg' => get_flash(),
        'add_entry_url' => uri_for('/add'),
        ###'entries' => $sth->fetchall_hashref('id'),
        'entries' => $entries,
        'spectab' => $spectab,
        'html' => $html,
      
    };
};
###
get '/Block' => sub {
    my $db = connect_db();
    my $sql = 'select id, parent, category, title, text from entries order by id desc';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;
    template 'show_entries_block.tt', {
        'msg' => get_flash(),
        'add_entry_url' => uri_for('/addblock'),
        'entries' => $sth->fetchall_hashref('id'),
    };
};

post '/addblock' => sub {
    if ( not session('logged_in') ) {
        send_error("Not logged in", 401);
    }

### 
    my $string = params->{'text'};
    my @array = split(/\n/,$string);
    foreach my $item (@array){
        chomp($item);
        print "\$item: $item\n";
           my $clean = cleaner($item);
         # my($parent,$category,$title,$text) = split(/\;\s?/,$clean);
          my($parent,$entryDate,$category,$title,$text,$status) = split(/\;\s?/,$clean);
           chomp($parent);
           chomp($entryDate);
           chomp($category);
           chomp($title);
           chomp($text);
           chomp($status);
           my $db = connect_db();
           my $sql = 'insert into entries (parent, entryDate, title, category, text, status) values (?, ?, ?, ?, ?, ?)';
           #my $sql = 'insert into entries (parent, category, title, text) values (?, ?, ?, ?)';
           ###$my $sql = "insert into entries (parent, category, title, text) values ($parent,$category,$title,$text)";
           print "$sql\n";
           my $sth = $db->prepare($sql) or die $db->errstr;
           #$sth->execute(params->{'parent'},params->{'category'},params->{'title'}, params->{'text'}) or die $sth->errstr;
           ###$sth->execute($parent,$category,$title,$text) or die $sth->errstr;
           $sth->execute($parent,$entryDate,$title,$category,$text,$status) or die $sth->errstr;

            #$sth->execute or die $sth->errstr;

 };
###
    set_flash('New entry posted!');
    redirect '/';
};
###


post '/add' => sub {
    if ( not session('logged_in') ) {
        send_error("Not logged in", 401);
    }

    my $db = connect_db();
    #my $sql = 'insert into entries (parent, category, title, text) values (?, ?, ?, ?)';
    my $sql = 'insert into entries (parent, entryDate, title, category, text, status) values (?, ?, ?, ?, ?, ?)';
    my $sth = $db->prepare($sql) or die $db->errstr;
    ### $sth->execute(params->{'parent'},params->{'category'},params->{'title'}, params->{'text'}) or die $sth->errstr;
    $sth->execute(params->{'parent'},params->{'entryDate'},params->{'title'},params->{'category'},params->{'text'},params->{'status'}) or die $sth->errstr;

    set_flash('New entry posted!');
    redirect '/';
};

any ['get', 'post'] => '/login' => sub {
    my $err;

    if ( request->method() eq "POST" ) {

        if ( params->{'username'} ne setting('username') ) {
            $err = "Invalid username";
        }
        elsif ( params->{'password'} ne setting('password') ) {
            $err = "Invalid password";
        }
        else {
            session 'logged_in' => true;
            set_flash('You are logged in.');
            return redirect '/';
        }
   }

   template 'login.tt', {
       'err' => $err,
   };
};

get '/logout' => sub {
   app->destroy_session;
   set_flash('You are logged out.');
   redirect '/';
};

get '/ACC' => sub {
    send_file 'table_v2.html';
};

get '/BCC' => sub {
    send_file 'table_v3.html';
};


init_db();
start;
###

###true;

### SUBS
### subs to make unique db
sub cleaner {
my($item) = @_;
 if ($item =~ s/[\x0a\x0d]//g){
   print "Found NL\n";
  };
 print "cleaner: $item\n";
 return $item;
};

sub testForFile {
 my($filename) = @_;
 my $uniqueDbName;
  print "Filename: $filename.\n";
  if (-f $filename) {
    print "File Exists!\n";
    open (my $fh, "$filename");
    my $line = <$fh>;
    chomp($line);
    $uniqueDbName = $line;
    print "DB name: $uniqueDbName.\n";
  } else {
    print "File does not exist. Making $filename\n";
    $uniqueDbName = createUniqueDbName();
    openFile($filename,$uniqueDbName);
  }
  return($uniqueDbName);
}

sub openFile {
  my($filename,$uniqueDbName) = @_;
  open( my $fh, ">","$filename") || die "Flaming death on creation of DB Flag file:$!\n";
  print "File open!\n";
  print $fh "$uniqueDbName\n";
  close $fh;
}

sub createUniqueDbName {
  my $time = time(); 
  my $rand = int(rand(10)); 
  my $name = "dancr_".$time.$rand.".db"; 
  print $name, "\n\n"; 
  return($name);
};

sub create_date {
  my($day, $month, $year)=(localtime)[3,4,5];
  # my $date = "$day-".($month+1)."-".($year+1900);
  my $date = ($month+1)."-"."$day-".($year+1900);
  # print "$date\n";
  return($date);
};

### subs to process format html output

sub evaluateLine {
 ($line) = @_;
###
my $actions = {
               'none' => sub { my $key = "1"; $hash{ $array[2] }{$key} = [ @array ]; },
               $hash{ $array[0] } => sub { my $key = create_entry_time(); $key = $key+$ii; $hash{ $array[0] }{$key} = [ @array ]; },
               '_DEFAULT_' => sub { die "Unrecognized token '$_[0]'; aborting\n" }
};
###
  chomp($line);
  chomp($_[0]);
  @array = split(/\;\s+/,$line);
  shift @array;  # remove first element
  my $type;
  if($array[0] =~ m/^(none)$/){
       $type = $1;
   };
     print "\$type: $type | \$_[0]: $_[0] | \$array[0]: $array[0]\n";
       my $action = $actions->{$type}
             || $actions ->{$array[0]}
             || $actions ->{_DEFAULT_};
        $action->($array[0], $type, $actions);
};

sub for_while_loop_2{
my(@AoA) = @_;
print "for_while Dumper\n";
print Dumper \@AoA;
print "for_while Dumper\n";
my $ii;
for my $i ( 0 .. $#AoA ){
    my $line;
    for my $j ( 0 .. $#{$AoA[$i]} ){
          if ( $j eq 0 ){
          $line = $AoA[$i][$j];
         } else {
           $line = $line."; ".$AoA[$i][$j];
        };
       chomp($line);
     };
       print "$ii: $line\n";
       $ii++;
       evaluateLine($line);
   };
};


sub style_ref_HoHoA_1_print_FH {
my($hash_ref,$html) = @_;
open  my ($fh), '>', \$html || die "Flaming death on open of $html: $! \n";
print "\n\n";
print $fh "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n";
print $fh "        \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n";
print $fh "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n";
print $fh "<head>\n";
print $fh "<meta http-equiv=\"Content-type\" content=\"text/html; charset=<% settings.charset %>\" />\n";
print $fh "<title>CS Project Dashboard</title>\n";
print $fh "<link rel=\"stylesheet\" href=\"http://10.80.8.12:443/css/style.css\" />\n";
print $fh "<!-- Grab jQuery from a CDN, fall back to local if necessary -->\n";
print $fh "<script src=\"//code.jquery.com/jquery-1.11.1.min.js\"></script>\n";
print $fh "<!-- End Comments -->\n";
print $fh "<style>\n";
print $fh "body {
    background-color: #ddd;
}
\n";
print $fh "\@media screen and (min-width: 480px) {
    body {
        background-color: cornflower;
    }
}\n";
print $fh "</style>\n";
my $big_string = "
  </head>
  <body>
    <div class=page>
    <h1>CS Dashboard</h1>
       <div class=metanav>
    </div>
  <ul class=entries>
  <table id=\"rounded-corner\" summary=\"Listing\"> 
\n";
#
print $fh "$big_string";
print $fh "<tbody bgcolor=\"#ffd\">\n";
print $fh "<tr style=\"background-color:darkblue; color:white;\">\n";
print $fh "<td>Heading OR Date</td>\n";
print $fh "<td>Staff</td>\n";
print $fh "<td>Parent</td>\n";
print $fh "<td>Note</td>\n";
print $fh "<td>Progress</td>\n";
print $fh "</tr>\n";
print $fh "</tbody>\n";
foreach my $key ( sort keys %$hash_ref ){
         print $fh "<!-- Start Heading -->\n";
         print $fh "<tbody>\n";
         print $fh "<tr style=\"background-color:#E6E6FA; color:black;\">\n";
         print $fh "<td>$key</td>\n";
         print $fh "</tr>\n";
         print $fh "</tbody>\n";
          my $count = 0;
          foreach my $entry ( reverse sort keys %{ $hash_ref->{$key} } ){
                    if ( $count == 0 ){
                    print $fh "<!-- Start Listing  $#array $count-->\n";
                     print $fh "  <tbody bgcolor=\"#ffd\">\n";
                      print $fh "  <tr class=\"flip\"; style=\"background-color:lightblue; color:black;\">\n";
                      $count++;
                       } else {
                          print $fh "<!-- Flip Start $#array $count-->\n";
                           print $fh "  <tbody class=\"section\" style=\"display: none;\">\n";
                           print $fh "  <tr>\n";
                     };
              my @array =  $hash_ref->{$key}->{$entry} ;
                  for my $i ( 0 .. $#array ) {
                    for my $j ( 2 .. $#{ $array[$i] } ) {
                     print $fh "  <td>$array[$i][$j]</td>\n";
                   }
             print $fh " </tr>\n";
             print $fh " </tbody>\n";
             print $fh "<!-- End -->\n";
                };
     print $fh "\n";
   };
  };
#
my $script = "<script>
\$('.flip').click(function() {
    \$(this)
        .closest('tbody')
        .next('.section')
        .toggle('fast');
});
</script>
";
 print $fh "$script\n";
 print $fh "</table>\n";
 print $fh "</div>\n";
 print $fh "</body>\n";
 print $fh "</html>\n";
 print $fh "\n\n";
 return ($html);
};

sub create_entry_time {
  my $entryTime = time();
  print $entryTime, "\n\n";
  return($entryTime);
};


true;
###
