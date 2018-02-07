use strict;

#environnement unix 
# testé avec 
#  perl 5.10.1
#  wget 1.12
#  UnZip 6.00 of 20 April 2009, by Info-ZIP. 

# url annuaire rpps national
my $url = 'https://annuaire.sante.fr/web/site-pro/extractions-publiques';

# download du html de la page
my $html = qx{wget --no-check-certificate --quiet --output-document=- $url};

# recherche d'un href pointant sur un zip
my $regex = qr/<a\s+(?:[^>]*?\s+)?href="([^"]*)zip"/p;

my $rpps_dir = 'rpps';
my $rpps_latest = 'rpps_latest.zip';

# si match du regexp
if ( $html =~ /$regex/g ) {
  print "Lien de telechargement du zip : $2 \n";

  print "Suppression de $rpps_latest \n";
  rmdir $rpps_dir ;
  unlink $rpps_latest;

  print "Téléchargement du zip $rpps_latest \n";
  system "wget --no-check-certificate --output-document=$rpps_latest $2";

  print "Extraction du zip $rpps_latest \n";
  # -d => création du fichier dans le répertoire dédié
  system "unzip $rpps_latest -d $rpps_dir ";

  my @file_list;
  find ( sub {
    return unless -f;       #Must be a file
    return unless /\.csv$/;  #Must end with `.pl` suffix
    push @file_list, $File::Find::name;
  }, $rpps_dir );

  print "Nettoyage de $rpps_dir/@file_list[0] \n";
  system "perl -i.bak -pe 's/(?<!\n)(?<=[^;])"?(?=[^;])//g;'  $rpps_dir/@file_list[0]";

  print "Renommage de $rpps_dir/@file_list[0] en $rpps_dir/rpps_latest_cleaned.csv \n";
  system "mv  $rpps_dir/@file_list[0] $rpps_dir/rpps_latest_cleaned.csv";
}

