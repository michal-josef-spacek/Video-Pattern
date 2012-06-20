package Video::Pattern;

# Pragmas.
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params);
use File::Basename qw(fileparse);
use File::Spec::Functions qw(catfile);
use IBSmm::Generator::Image::Random;
use Video::Delay::Const;

# Version.
our $VERSION = 0.01;

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
		$self->{'image_generator'} = IBSmm::Generator::Image::Random
			->new(

			'color_random' => 1,
			'height' => 100,
			'type' => $self->{'image_type'},
			'width' => 100,
		);
	} else {
		$self->{'image_type'} = $self->{'image_generator'}->type;
	}

	# Object.
	return $self;
}

# Create value.
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
			symlink $image_filename, $image_path;
		}

		# Decrement delay.
		$delay -= 1000 / $self->{'fps'};
	}
	return;
}

1;

__END__
