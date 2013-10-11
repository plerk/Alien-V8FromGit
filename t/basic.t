use strict;
use warnings;
use Test::More tests => 5;
use Alien::V8FromGit;
use URI::file;
use File::Spec;

do {
  my $tmp_dir = Alien::V8FromGit->_tmp_dir;
  ok -d $tmp_dir, "tmp_dir = $tmp_dir";
};

isa_ok(Alien::V8FromGit->_git_uri, 'URI', Alien::V8FromGit->_git_uri);

do {
  my $git = Git::Wrapper->new(Alien::V8FromGit->_tmp_dir('source'));
  $git->init;
  my $fh;
  open($fh, '>', File::Spec->catfile($git->dir, 'foo.txt'));
  print $fh "hi there\n";
  close $fh;
  $git->add('foo.txt');
  $git->commit({ message => 'initial commit' });
  my $uri = URI::file->new($git->dir);
  $uri->host('localhost');
  $ENV{ALIEN_V8FROMGIT_URL} = $uri->as_string;
};

isa_ok(Alien::V8FromGit->_git_uri, 'URI', Alien::V8FromGit->_git_uri);

my $git = Alien::V8FromGit->git;
isa_ok $git, 'Git::Wrapper';

ok( -e File::Spec->catfile($git->dir, 'foo.txt'), "has foo.txt" );
