# Pragmas.
use strict;
use warnings;

# Modules.
use inc::Module::Install;

# Definition.
abstract 'Perl class for video frames pattern generating.';
author 'Michal Spacek <skim@cpan.org>';
license 'bsd';
name 'Video-Pattern';
requires 'Class::Utils' => 0.03;
requires 'File::Basename' => 0;
requires 'File::Spec::Functions' => 0;
requires 'Image::Random' => 0;
requires 'Video::Delay::Const' => 0;
resources 'bugtracker' => 'https://rt.cpan.org/Public/Dist/Display.html'.
	'?Name=Video-Pattern';
resources 'homepage' => 'https://github.com/tupinek/Video-Pattern';
resources 'repository' => 'git://github.com/tupinek/Video-Pattern';
test_requires 'English' => 0;
test_requires 'File::Object' => 0.05;
test_requires 'List::MoreUtils' => 0;
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
test_requires 'Test::Pod' => 0;
test_requires 'Test::Pod::Coverage' => 0;
tests_recursive;
version '0.01';

# Run.
WriteAll();
