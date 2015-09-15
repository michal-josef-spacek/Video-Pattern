package Video::Pattern;

# Pragmas.
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params);
use English;
use File::Basename qw(fileparse);
use File::Spec::Functions qw(catfile);
use Image::Random;
use Video::Delay::Const;

# Version.
our $VERSION = 0.06;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Delay generator.
	$self->{'delay_generator'} = Video::Delay::Const->new(
		'const' => 1000,
	);

	# Duration.
	$self->{'duration'} = 10000;

	# Frame per second.
	$self->{'fps'} = 60;

	# Image generator.
	$self->{'image_generator'} = undef;

	# Image type.
	$self->{'image_type'} = 'bmp';

	# Process params.
	set_params($self, @params);

	# Own image generator.
	if (! defined $self->{'image_generator'}) {
		$self->{'image_generator'} = Image::Random->new(
			'height' => 1080,
			'type' => $self->{'image_type'},
			'width' => 1920,
		);
	} else {
		$self->{'image_type'} = $self->{'image_generator'}->type;
	}

	# Object.
	return $self;
}

# Create images to output directory.
sub create {
	my ($self, $output_dir) = @_;
	my $delay = 0;
	my $image;
	foreach my $frame_num (0 .. $self->{'duration'} / 1000
		* $self->{'fps'}) {

		my $image_path = catfile($output_dir,
			(sprintf '%03d', $frame_num).'.'.
			$self->{'image_type'});

		# Create new image.
		if ($delay <= 0) {
			$self->{'image_generator'}->create($image_path);
			$image = $image_path;
			$delay = $self->{'delay_generator'}->delay;

		# Symlink to old image.
		} else {
			my ($image_filename) = fileparse($image);
			$self->_symlink($image_filename, $image_path);
		}

		# Decrement delay.
		$delay -= 1000 / $self->{'fps'};
	}
	return;
}

# Symlink.
sub _symlink {
	my ($self, $from, $to) = @_;
	if ($OSNAME eq 'MSWin32') {
		eval {
			require Win32::Symlink;
		};
		my $has_symlink;
		if (! $EVAL_ERROR) {
			$has_symlink = eval {
				Win32::Symlink::symlink($from => $to);
			};
		}
		if (! $has_symlink) {
			require File::Copy;
			File::Copy::copy($from, $to);
		}
	} else {
		symlink $from, $to;
	}
}
1;

__END__

=pod

=encoding utf8

=head1 NAME

Video::Pattern - Video class for frame generation.

=head1 SYNOPSIS

 use Video::Pattern;
 my $pattern = Video::Pattern->new(%parameters);
 $pattern->create($output_dir);

=head1 METHODS

=over 8

=item C<new(%parameters)>

 Constructor

=over 8

=item * C<delay_generator>

 Delay generator object.
 Default value is Video::Delay::Const with 1_000 milisecond constant.

=item * C<duration>

 Video duration.
 Default value is 10_000 miliseconds.

=item * C<fps>

 Frames per second.
 Default value is 60.

=item * C<image_generator>

 Image generator object.
 Default value is Image::Random object with 1920 width, 1080
 height, image type 'image_type and random colors.

=item * C<image_type>

 Image type.
 Default value is 'bmp' which isn't defined user 'image_generator'.

=back

=item C<create($output_dir)>

 Create images to output directory.
 Returns undef.

=back

=head1 ERRORS

 new():
         From Class::Utils::set_params():
                 Unknown parameter '%s'.

=head1 EXAMPLE

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use File::Temp qw(tempdir);
 use File::Path qw(rmtree);
 use Video::Pattern;

 # Object.
 my $obj = Video::Pattern->new(
        'duration' => 10000,
        'fps' => 2,
 );

 # Temporary directory.
 my $temp_dir = tempdir();

 # Create frames.
 $obj->create($temp_dir);

 # List and print files in temporary directory.
 system "ls -l $temp_dir";

 # Remove temporary directory.
 rmtree $temp_dir;

 # Output on system supporting links like:
 # celkem 66968
 # -rw-r--r-- 1 foobar foobar 6220854 20. čen 12.09 000.bmp
 # lrwxrwxrwx 1 foobar foobar       7 20. čen 12.09 001.bmp -> 000.bmp
 # -rw-r--r-- 1 foobar foobar 6220854 20. čen 12.09 002.bmp
 # lrwxrwxrwx 1 foobar foobar       7 20. čen 12.09 003.bmp -> 002.bmp
 # -rw-r--r-- 1 foobar foobar 6220854 20. čen 12.09 004.bmp
 # lrwxrwxrwx 1 foobar foobar       7 20. čen 12.09 005.bmp -> 004.bmp
 # -rw-r--r-- 1 foobar foobar 6220854 20. čen 12.09 006.bmp
 # lrwxrwxrwx 1 foobar foobar       7 20. čen 12.09 007.bmp -> 006.bmp
 # -rw-r--r-- 1 foobar foobar 6220854 20. čen 12.09 008.bmp
 # lrwxrwxrwx 1 foobar foobar       7 20. čen 12.09 009.bmp -> 008.bmp
 # -rw-r--r-- 1 foobar foobar 6220854 20. čen 12.09 010.bmp
 # lrwxrwxrwx 1 foobar foobar       7 20. čen 12.09 011.bmp -> 010.bmp
 # -rw-r--r-- 1 foobar foobar 6220854 20. čen 12.09 012.bmp
 # lrwxrwxrwx 1 foobar foobar       7 20. čen 12.09 013.bmp -> 012.bmp
 # -rw-r--r-- 1 foobar foobar 6220854 20. čen 12.09 014.bmp
 # lrwxrwxrwx 1 foobar foobar       7 20. čen 12.09 015.bmp -> 014.bmp
 # -rw-r--r-- 1 foobar foobar 6220854 20. čen 12.09 016.bmp
 # lrwxrwxrwx 1 foobar foobar       7 20. čen 12.09 017.bmp -> 016.bmp
 # -rw-r--r-- 1 foobar foobar 6220854 20. čen 12.09 018.bmp
 # lrwxrwxrwx 1 foobar foobar       7 20. čen 12.09 019.bmp -> 018.bmp
 # -rw-r--r-- 1 foobar foobar 6220854 20. čen 12.09 020.bmp

=head1 DEPENDENCIES

L<Class::Utils>,
L<English>,
L<File::Basename>,
L<File::Spec::Functions>,
L<Image::Random>,
L<Video::Delay::Const>.

On Windows L<File::Copy> or L<Win32::Symlink>.

=head1 SEE ALSO

L<Video::Delay::Array>,
L<Video::Delay::Const>,
L<Video::Delay::Func>.

=head1 REPOSITORY

L<https://github.com/tupinek/Video-Pattern>

=head1 AUTHOR

Michal Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

 © 2012-2015 Michal Špaček
 BSD 2-Clause License

=head1 VERSION

0.06

=cut
