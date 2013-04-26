
$Test::Class::TRA::Mechanize::VERSION = '0.0000.000001'; #vvery vvery beta
use lib qw( C:\johns\Dropbox\Code_Base\CPAN\Test-Class-Rig\lib );
#use lib 'C:\Users\John Scoles\Dropbox\Code_Base\CPAN\Test-Class-Rig\lib';
#           C:\Users\John Scoles\Dropbox\Code_Base\CPAN\Test-Class-Rig\lib\Test\Class);
{ package
  Test::Class::TRA::Mechanize;
  use Test::Class::Rig();
  use WWW::Mechanize;
  use Exporter();
  @ISA = qw(Exporter WWW::Mechanize);
  use Data::Dumper;
  $trarh = undef;	# holds agent handle once initialized
  sub agent {
    return $trarh if $trarh;
    my($class, $attr) = @_;
    $class .= "::tra";
    # not a 'my' since we use it above to prevent multiple drivers
    #warn("end here agent $class");
    $trarh = Test::Class::Rig::_new_trarh($class,"WWW::Mechanize", {
        'Name' => 'Mechanize',
        'Version' => $VERSION,
        'Err'    => \my $err,
        'Errstr' => \my $errstr,
        'Attribution' => "TRA::Mechanize $VERSION using Test::Class::Rig by John Scoles",
        });
    return $trarh;
  }
{ package
  Test::Class::TRA::Mechanize::tra;
  use Test::More;
  use Test::Builder;
 # use HTML::TreeBuilder::XPath;
  #use HTML::TreeBuilder::Select;
  use strict;
  Test::Class::Rig::tra->attributes({SCALARS=>[qw(_content_tree _content)]});
  our $AUTOLOAD;
  my $Test = Test::Builder->new;
  $Test->exported_to(__PACKAGE__);
  my %comparator = (
    is       => 'is_eq',
    isnt     => 'isnt_eq',
    like     => 'like',
    unlike   => 'unlike',
  );
my %no_locator = map { $_ => 1 }
                qw( speed alert confirmation prompt get_location title
                    body_text all_buttons all_links all_fields
                    mouse_speed all_window_ids all_window_names
                    all_window_titles html_source cookie absolute_location );
sub no_locator {
    my $self   = shift;
    my $method = shift;
    return $no_locator{$method};
}
  sub load_agent {
    my $self = shift;
    my ($attr)= @_;
    $attr = {$attr,cookie_jar => {}, autocheck => 0};
    my $agent  = Test::Class::Rig::rig::_new_agent($self,$attr);
    return $agent;
  }
  # sub double_click {
    # my $self = shift;
    # my ($locator) = @_;
   #
  # }
#
  # sub context_menu {
    #
  # }
  #
  # sub click_at {
    #
  # }
  #
  # sub double_click_at {
    #
  # }
  #
  #
  # sub context_menu_at {
    #
  # }
  #
  # sub fire_event {
    #
  # }
  #
  # sub focus {
    #
  # }
  #
  # sub key_press {
    #
  # }
  #
  # sub shift_key_down {
    #
  # }
  #
  # sub shif_key_up {
    #
  # }
  #
  sub pause {
    my $self = shift;
    my ($ms) =  @_;
    $ms|=1000;
    sleep($ms/1000);
  }
  sub ping {
    warn("this is tra ping 'Test::Class::TRA::Mechanize::tra'\n")
  }
#} #Test::Class::Rig::trd
# { package
  # Test::Class::TRA::Mechanize::tra::checks;
  # use strict;
  sub open {
    my $self  = shift;
    my ($url) = @_;
    my $resp=$self->get($url);
     if( $resp->is_redirect ) {
     #    warn(" open redirected!!");
         my $location = $resp->header( "Location" );
     #     warn(" open redirecded to Location=$location");
        # # # my $uri = new URI( $location );
        # # # my $new_url = $uri->scheme . $uri->opaque;
        # # # $self->get($new_url);
# # # And here is where you do the load of the new URL.
     }
#    warn("\n open $url sucess=".ref($resp)." resp error=".$resp->is_error()." header Location=".$resp->header( "Location" ))
     #if ($resp);
#    $self->_content($resp);
    return $resp
      unless ($resp->is_error());
   # my $root = HTML::TreeBuilder::Select->new_from_content($self->content());
   # $self->_content_tree($root);
    return 0;
  }
  sub get_location {
    my $self = shift;
     # warn("in get location self $self\n");
    return undef
      unless($self->response());
    my $uri  = $self->uri();
    #warn("in get location uri=".$uri->as_string());
    return $uri->as_string();
  }
  sub  submit {
    my $self = shift;
    my ($locator) = @_;
#    warn("select locator= ".Dumper($locator)."value=".$value);
    $self->_get_form($locator->{form})
       if ($locator);
    my $resp = undef;
    eval {
      $resp = $self->WWW::Mechanize::submit();
    };
    if ($@) {
      use Data::Dumper;
     # warn("Error on  submit".Dumper($@));
      my $err = $@;
      return 0;
    }
     $self->_check_redirect($resp);
    return $resp;
  }
  sub  select {
    my $self = shift;
    my ($locator,$value) = @_;
#    warn("select locator= ".Dumper($locator)."value=".$value);
    $self->_get_form($locator->{form});
    eval {
      $self->WWW::Mechanize::select($locator->{name},$value);
    };
    if ($@) {
      use Data::Dumper;
      warn("Error! ".Dumper($@)." on  select. Locator=".Dumper($locator)." value=".$value);
      my $err = $@;
      return 0;
    }
    return 1;
  }
  sub  type {
    my $self = shift;
    my ($locator, $value) = @_;
    $self->_get_form($locator->{form});
  #  warn("type locator= ".$locator->{name}." value=".$value);
    eval {
      $self->set_fields( $locator->{name} => "$value");
    };
    if ($@) {
      use Data::Dumper;
      warn("type error=".Dumper($@));
      my $err = $@;
      return 0;
    }
    return 1;
  }
  sub _get_form {
    my $self      = shift;
    my ($locator) = @_;
   # warn ("\n\n _get_form locator = ".Dumper($locator)."\n\n");
    my $form;
    if ($locator->{name}){
      #warn("form number name=".$locator->{name});
      $form = $self->form_name($locator->{name});
    }
    elsif ($locator->{number}){
#      warn("form number number=".$locator->{number});
      $form = $self->form_number($locator->{number});
    }
    else {
     #error
    }
    use Data::Dumper;
    #warn("get form =".ref($form));
  }
  sub _check_redirect {
    my $self = shift;
    my ($resp) = @_;
    if( $resp->is_redirect ) {
    #   warn(" _check_redirect redirected!!");
        my $location = $resp->header( "Location" );
         my $uri = new URI( $location );
         my $new_url = $uri->scheme . $uri->opaque;
        #  warn("_check_redirect redirecded new_url=$new_url on more base=".$resp->base);
          $resp=$self->get($new_url);
# And here is where you do the load of the new URL.
    }
  }
  sub get_text {
    my $self = shift;
    my ($text) = @_;
    my $content = $self->content();
    return 1
      if (index($content,$text) >= 0);
    return 0;
  }
  sub click {
    my $self = shift;
    my ($locator) = @_;
    use Data::Dumper;
 #   warn("click locator=".Dumper($locator));
    my $get;
    if (lc($locator->{tag}) eq 'a') {
      eval {
    #     warn("click=".$locator->{type},",".$locator->{value});
         my $type = $locator->{type};
        my @get= $self->links();#= $self->find_link(text =>'Register a License',n=>2);
          #warn("get=".Dumper(\@get));
      };
    }
    else {
   # $self->_get_form($locator);
    eval {
        if ($locator->{number}){
 #          warn('click number');
           $get =$self->click_button((number=>$locator->{number}));
        }
        elsif ($locator->{name}) {
 #          warn('click name');
           $get =$self->click_button((name=>$locator->{name}));
        }
    #      warn("get base= is_redirect ".$self->base());
#
   #       warn("get base= as_string".$get->as_string);
   #       $self->open_ok('https://10.44.59.171'.$get->header( 'Location' ));
      };
    }
#    warn("what I got=".ref($get)." click error=".Dumper($@));
     if ($@) {
       my $err = $@;
       return 0;
     }
    $self->_check_redirect($get);
    return $get;
  }
  sub _locate_on_tree {
     my $self = shift;
     my ($locator) = @_;
     my $tree =  $self->_content_tree();
     if (index($locator,"identifier=") == 0 || index($locator,"id=") == 0){
        my $id = substr($locator,11,length($locator));
        #warn("id=$id\n");
        my @finds = $tree->look_down('id','searchfield');
        use Data::Dumper;
    #    warn("test finds=".Dumper(\@finds));
     }
   }
  sub AUTOLOAD {
    # (my $constname = $AUTOLOAD) =~ s/.*:://;
    # my $val = constant($constname);
    # *$AUTOLOAD = sub { $val };
    # goto &$AUTOLOAD;
    my $name = $AUTOLOAD;
    $name =~ s/.*:://;
   # warn("MEC Autoload name = $name\n");
    return if $name eq 'DESTROY';
    my $self = $_[0];
    my $sub;
    if ($name =~ /(\w+)_(is|isnt|like|unlike)$/i) {
        my $getter = "$1";
         # warn("\n1=".$1);
         # warn("\ngetter=".$getter);
        my $comparator = $comparator{lc $2};
# warn("\ncomparator=".$comparator);
        # make a subroutine that will call Test::Builder's test methods
        # with selenium data from the getter
        if ($self->no_locator($1)) {
            $sub = sub {
                my( $self, $str, $name ) = @_;
 #               warn("no_locator function self=".$self." str=".$str." name=".$name."\n");
                 #diag "Test::Class::TRA::Mechanize running $getter (@_[1..$#_])"
                    # if $self->{verbose};
                $name = "$getter, '$str'"
                    if $self->{default_names} and !defined $name;
                no strict 'refs';
  #              warn("no_locator function self=".$getter." str=".$str." name=".$name."\n");
                my $rc = $Test->$comparator( $self->$getter, $str, $name );
                if (!$rc && $self->error_callback) {
                  &{$self->error_callback}( $name, $self );
                }
   #             warn("RC=".$rc."\n");
                return $rc;
            };
        }
        else {
            $sub = sub {
                my( $self, $locator, $str, $name ) = @_;
                #warn("\n\n locator self=".$self." locator=".$locator." str=".$str." name=".$name."\n");
                 #diag "Test::Class::TRA::Mechanize running $getter (@_[1..$#_])"
                 #   if $self->{verbose};
                $name = "$getter, $locator, '$str'"
                    if $self->{default_names} and !defined $name;
                no strict 'refs';
                my $rc = $Test->$comparator( $self->$getter($locator), $str, $name );
                if (!$rc && $self->error_callback) {
                    &{$self->error_callback}( $name, $self );
                }
                return $rc;
            };
        }
    }
    elsif ($name =~ /(\w+?)_?ok$/i) {
        my $cmd = $1;
        # make a subroutine for ok() around the selenium command
        $sub = sub {
            my( $self, $arg1, $arg2, $name ) = @_;
            #warn("\n in a made up sub 1 $self,a1=$arg1,a2=$arg2,n=$name\n");
            if ($self->{default_names} and !defined $name) {
                $name = $cmd;
                $name .= ", $arg1" if defined $arg1;
                #$name .= ", $arg2" if defined $arg2;
            }
            #warn("\n in a made up sub 2 $self,a1=$arg1,a2=$arg2,n=$name\n");
            diag "Test::Class::TRA::Mechanize running $cmd (@_[1..$#_])"
              if $self->{verbose};
            local $Test::Builder::Level = $Test::Builder::Level + 1;
            my $rc = '';
            eval { $rc = $self->$cmd( $arg1, $arg2 ) };
            die $@ if $@ and $@ =~ /Can't locate object method/;
            diag($@) if $@;
            $rc = ok( $rc, $name );
            if (!$rc && $self->error_callback) {
                &{$self->error_callback}( $name, $self );
            }
            return $rc;
        };
    }
    # jump directly to the new subroutine, avoiding an extra frame stack
    if ($sub) {
        no strict 'refs';
        *{$AUTOLOAD} = $sub;
        goto &$AUTOLOAD;
    }
    else {
        # try to pass through to WWW::Mechanize
        my $sel = 'Test::Class::TRA::Mechanize';
        my $sub = "${sel}::${name}";
        goto &$sub if exists &$sub;
        my ($package, $filename, $line) = caller;
        die qq(Can't locate object method "$name" via package ")
            . __PACKAGE__
            . qq(" (also tried "$sel") at $filename line $line\n);
    }
  }
  sub error_callback {
    my ($self, $cb) = @_;
    if (defined($cb)) {
        $self->{error_callback} = $cb;
    }
    return $self->{error_callback};
  }
} #Test::Class::TRA::Mechanize::tra
} #Test::Class::TRA::Mechanize;
1;
__END__
