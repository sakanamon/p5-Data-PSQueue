package test::Data::PSQueue;
use strict;
use warnings;
use base qw(Test::Class);
use Test::More;
use Data::Dumper;

BEGIN { use_ok('Data::PSQueue') }
require_ok('Data::PSQueue');

sub binding: Tests {
    use_ok('Data::PSQueue::Binding');
    
    # string-keyed binding
    my $sb = Data::PSQueue::Binding->new('test', 0);
    isa_ok($sb, 'Data::PSQueue::Binding');
    is($sb->key, 'test');
    is($sb->prio, 0);

    my $sf = $sb->compare;
    is($sf->($sb->key, 'test'), 0);
    is($sf->($sb->key, ''),     1);
    is($sf->($sb->key, 'zoo'), -1);

    # numeric-keyed binding
    my $nb = Data::PSQueue::Binding->new(1000, 0);
    is($nb->key, 1000);
    is($nb->prio, 0);

    my $nf = $nb->compare;
    is($nf->($nb->key, 1000),   0);
    is($nf->($nb->key, 100),    1);
    is($nf->($nb->key, 10000), -1);
}

sub empty: Tests {
    # empty queue
    my $q = Data::PSQueue->empty;
    isa_ok($q, 'Data::PSQueue::PSQ::Void');
    ok($q->is_empty);
    ok(!$q->is_singleton);

    my @a = $q->to_ordered_list;
    is($#a + 1, 0);

    # singleton queue
    my $r = $q->insert('test', 0);
    isa_ok($r, 'Data::PSQueue::PSQ::Winner');
    ok(!$r->is_empty);
    ok($r->is_singleton);

    my @b = $r->to_ordered_list;
    is(scalar @b, 1);
    isa_ok($b[0], 'Data::PSQueue::Binding');    
}

sub singleton: Tests {
    my $q = Data::PSQueue->singleton('test', 0);
    isa_ok($q, 'Data::PSQueue::PSQ::Winner');
    ok(!$q->is_empty);
    ok($q->is_singleton);
    is_deeply($q, Data::PSQueue->empty->insert('test', 0));
    
    my @a = $q->to_ordered_list;
    is(scalar @a, 1);
    isa_ok($a[0], 'Data::PSQueue::Binding');
    is($a[0]->key, 'test');
    is($a[0]->prio, 0);
}

sub tournament: Tests {
    my $q = Data::PSQueue->singleton("Nigel", 7)
                   ->insert("Doaitse", 2)
                   ->insert("Lambert", 3)
                   ->insert("Ade", 4)
                   ->insert("Vladimir", 8)
                   ->insert("Elco", 1)
                   ->insert("Johan", 6)
                   ->insert("Piet", 5);

    my $min = $q->find_min;
    is($min->key, "Elco");
    is($min->prio, 1);

    my @a = $q->to_ordered_list;
    is(scalar @a, 8);
    is($a[0]->key, "Ade");
    is($a[0]->prio, 4);

    $q = $q->delete_min;

    $min = $q->find_min;
    is($min->key, "Doaitse");
    is($min->prio, 2);
    
    @a = $q->to_ordered_list;
    is(scalar @a, 7);
    is($a[0]->key, "Ade");
    is($a[0]->prio, 4);
}

sub semi_heap_conditions: Tests {
}

sub search_tree_conditions: Tests {
}

sub key_conditions: Tests {
}

sub finate_map_conditions: Tests {
    my $q = Data::PSQueue->empty;
    for (my $i = 0; $i < 100; $i++) {
        $q = $q->insert(int(rand($i * 100)), int(rand($i * 1000)));
    }

    my %visited;
    for my $binding ($q->to_ordered_list) {
        $visited{$binding->key} = $visited{$binding->key} ?
                                      $visited{$binding->key} + 1 : 1;
    }

    for my $value (values(%visited)) {
        cmp_ok($value, '==', 1);
    }
}

__PACKAGE__->runtests;

1;