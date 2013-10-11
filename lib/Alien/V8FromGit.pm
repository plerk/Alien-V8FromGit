package Alien::V8FromGit;

use strict;
use warnings;
use URI;
use Git::Wrapper;
use File::Temp qw( tempdir );
use File::Spec;
use File::Path qw( make_path );

# ABSTRACT: Builds and installs the V8 JavaScript engine from Git
# VERSION

sub _git_uri
{
  URI->new($ENV{ALIEN_V8FROMGIT_URL} || "https://github.com/v8/v8.git");
}

our $dir = $ENV{ALIEN_V8FROMGIT_DIR};

sub _tmp_dir
{
  my $class = shift;
  unless($dir)
  {
    $dir = tempdir( CLEANUP => 1 );
  }
  my $tmp = File::Spec->catdir($dir, @_);
  make_path($tmp, { verbose => 0, mode => 0700 });
  $tmp;
}


our $git;

sub git
{
  unless(defined $git)
  {
    $git = Git::Wrapper->new(__PACKAGE__->_tmp_dir('v8'));
    rmdir $git->dir;
    $git->clone(__PACKAGE__->_git_uri, $git->dir);
  }
  $git;
}

sub _version_cmp
{
  my $class = shift;
  my @a = @{ $_[0] };
  my @b = @{ $_[1] };
  while(defined($a[0]) && defined($b[0]))
  {
    my $cmp = shift(@a) <=> shift(@b);
    return $cmp if $cmp;
  }
  return 0;
}

sub versions
{
  map { join '.', @$_ } 
  sort { __PACKAGE__->_version_cmp($a,$b) } 
  map { [split /\./] }
  __PACKAGE__->git->tag;
}

sub latest_version { (__PACKAGE__->versions)[-1] }

1;
