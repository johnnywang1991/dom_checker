#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
use Data::Dumper;
use Smart::Comments;
use Mojo::UserAgent;
use Mojo::IOLoop;
use Parallel::ForkManager;

my $ua = Mojo::UserAgent->new;
my $pm = Parallel::ForkManager->new(150);
my @suffixs = qw/.me/;
while (<>) {
    my $pid = $pm->start and next;
    s/(\W|\d)//g;
    for my $suffix (@suffixs) {
        my $domain = $_ . $suffix;
        domava($domain);
    }   
    $pm->finish;
}
sub domava {
    my $domain = shift @_; 
    $ua->get("http://panda.www.net.cn/cgi-bin/check.cgi?area_domain=$domain" => {
        'accept'    => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'user-agent' => 'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36',
        'accept-encoding' => 'gzip,deflate,sdch', 
        'accept-language' => 'zh-CN,zh;q=0.8',
        'charset' => 'ISO-8859-1'
        } => sub {
            my $self = shift;
            my $result = shift;
            if ($result->success) {
                my $dominfo = $result->res->dom->at('property original')->text;
                my ($code, $info) = split(/:/, $dominfo);
                $code =~ s/\s//g;
                say $domain if $code == "210"
            } else {
                # say $result->error;
            }   
        }); 
    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
}
$pm->wait_all_children;
