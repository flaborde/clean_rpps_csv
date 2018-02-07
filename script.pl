use strict;
use File::Find;
use File::Path;

#environnement unix 
# testé avec 
#  perl 5.10.1
#  wget 1.12
#  UnZip 6.00 of 20 April 2009, by Info-ZIP. 

# url annuaire rpps national
my $url = 'https://service.annuaire.sante.fr/annuaire-sante-webservices/V300/services/extraction/ExtractionMonoTable_CAT18_ToutePopulation';

my $rpps_dir = 'rpps';
my $rpps_latest = 'rpps_latest.zip';

print "Lien de telechargement du zip : $url \n";

print "Suppression de $rpps_latest \n";
rmtree ($rpps_dir) ;
unlink $rpps_latest;

print "Téléchargement du zip $rpps_latest \n";
system "wget --no-check-certificate --output-document=$rpps_latest $url";

print "Extraction du zip $rpps_latest \n";
# -d => création du fichier dans le répertoire dédié
system "unzip $rpps_latest -d $rpps_dir ";

my @file_list;
find ( sub {
   return unless -f;       #Must be a file
   return unless /\.csv$/;  #Must end with `.csv` suffix
   push @file_list, $File::Find::name;
}, $rpps_dir );

my $file =  @file_list[0];

print "Nettoyage de $file \n";

rename($file, $file.'.bak');
open(IN, '<'.$file.'.bak') or die $!;
open(OUT, '>'.$file) or die $!;
while(<IN>){
    $_ =~ s/(?<!\n)(?<=[^;])"?(?=[^;])//g;
}
close(IN);
close(OUT);

print "Renommage de $file en $rpps_dir/rpps_latest_cleaned.csv \n";
system "mv  $file $rpps_dir/rpps_latest_cleaned.csv";
