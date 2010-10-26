use lib './t';
use Test::More;
use strict;
use warnings;


BEGIN {
    eval "use DBD::SQLite";
    plan skip_all => "DBD::SQLite is not installed. skip testing" if $@;
}

use Mock::MultiPK;
use Data::Dumper;

my $skinny = Mock::MultiPK->new;

{
    subtest 'init data' => sub {
        $skinny->setup_test_db;

        $skinny->insert( 'a_multi_pk_table', { id_a => 1, id_b => 1 } );
        $skinny->insert( 'a_multi_pk_table', { id_a => 1, id_b => 2 } );
        $skinny->insert( 'a_multi_pk_table', { id_a => 1, id_b => 3 } );
        my $data = $skinny->insert( 'a_multi_pk_table', { id_a => 2, id_b => 1 } );
        $skinny->insert( 'a_multi_pk_table', { id_a => 2, id_b => 2 } );

        is( $data->id_a, 2 );
        is( $data->id_b, 1 );

        $skinny->insert( 'a_multi_pk_table', { id_a => 3, id_b => 10 } );
        $skinny->insert( 'a_multi_pk_table', { id_a => 3, id_b => 20 } );
        $skinny->insert( 'a_multi_pk_table', { id_a => 3, id_b => 30 } );

        done_testing;
    };

    my ( $itr, $a_multi_pk_table );

    subtest 'multi pk search' => sub {
        $itr = $skinny->search( 'a_multi_pk_table', { id_a => 1 } );
        is( $itr->count, 3, 'first - user has 3 books' );

        $a_multi_pk_table = $skinny->single( 'a_multi_pk_table', { id_a => 1, id_b => 3 } );
        ok( $a_multi_pk_table );
        is( $a_multi_pk_table->memo, 'foobar' );
        $a_multi_pk_table->update( { memo => 'hoge' } );

        $a_multi_pk_table = $skinny->single( 'a_multi_pk_table', { id_a => 1, id_b => 3 } );
        is( $a_multi_pk_table->memo, 'hoge', 'update' );

        $a_multi_pk_table->delete;

        $itr = $skinny->search( 'a_multi_pk_table', { id_a => 1 } );
        is( $itr->count, 2, 'delete and user has 2 books' );
        ok ( not $skinny->single( 'a_multi_pk_table', { id_a => 1, id_b => 3 } ) );

        $a_multi_pk_table = $skinny->search( 'a_multi_pk_table', { id_a => 1 } )->first;
        ok( $a_multi_pk_table );

        my ( $id_a, $id_b ) = ( $a_multi_pk_table->id_a, $a_multi_pk_table->id_b );

        $a_multi_pk_table->delete;

        ok ( not $skinny->single( 'a_multi_pk_table', { id_a => $id_a, id_b => $id_b } ) );

        done_testing();
    };

    subtest 'multi pk search_by_sql' => sub {
        my ( $itr, $row );

        $itr = $skinny->search_by_sql(q{SELECT * FROM a_multi_pk_table WHERE id_a = ? AND id_b = ?}, [3, 10], 'a_multi_pk_table');

        is( $itr->count, 1 );

        $row = $itr->first;
        is( $row->memo, 'foobar' );
        $row->update( { memo => 'hoge' } );

        $row = $skinny->search_by_sql(q{SELECT * FROM a_multi_pk_table WHERE id_a = ? AND id_b = ?}, [3, 10])->first;

        is( $row->memo, 'hoge' );

        done_testing();
    };

    subtest 'multi pk row insert' => sub {
        my ( $rs, $itr, $row );

        $row = $skinny->insert( 'a_multi_pk_table', { id_a => 3, id_b => 40 } );

        is_deeply( $row->get_columns, { id_a => 3, id_b => 40 } );

        $row->insert(); # find_or_create => find

        $itr = $skinny->search( 'a_multi_pk_table', { id_a => 3 } );
        is( $itr->count, 4 );

        $row->delete();

        $itr = $skinny->search( 'a_multi_pk_table', { id_a => 3 } );
        is( $itr->count, 3 );

        done_testing();
    };
}

{
    subtest 'init data' => sub {
        $skinny->setup_test_db;

        $skinny->insert( 'c_multi_pk_table', { id_c => 1, id_d => 1 } );
        $skinny->insert( 'c_multi_pk_table', { id_c => 1, id_d => 2 } );
        $skinny->insert( 'c_multi_pk_table', { id_c => 1, id_d => 3 } );
        my $data = $skinny->insert( 'c_multi_pk_table', { id_c => 2, id_d => 1 } );
        $skinny->insert( 'c_multi_pk_table', { id_c => 2, id_d => 2 } );

        is( $data->id_c, 2 );
        is( $data->id_d, 1 );

        $skinny->insert( 'c_multi_pk_table', { id_c => 3, id_d => 10 } );
        $skinny->insert( 'c_multi_pk_table', { id_c => 3, id_d => 20 } );
        $skinny->insert( 'c_multi_pk_table', { id_c => 3, id_d => 30 } );

        done_testing;
    };


    my ( $itr, $a_multi_pk_table );

    subtest 'multi pk search' => sub {
        $itr = $skinny->search( 'c_multi_pk_table', { id_c => 1 } );
        is( $itr->count, 3, 'first - user has 3 books' );

        $a_multi_pk_table = $skinny->single( 'c_multi_pk_table', { id_c => 1, id_d => 3 } );
        ok( $a_multi_pk_table );
        is( $a_multi_pk_table->memo, 'foobar' );
        $a_multi_pk_table->update( { memo => 'hoge' } );

        $a_multi_pk_table = $skinny->single( 'c_multi_pk_table', { id_c => 1, id_d => 3 } );
        is( $a_multi_pk_table->memo, 'hoge', 'update' );

        $a_multi_pk_table->delete;

        $itr = $skinny->search( 'c_multi_pk_table', { id_c => 1 } );
        is( $itr->count, 2, 'delete and user has 2 books' );
        ok ( not $skinny->single( 'c_multi_pk_table', { id_c => 1, id_d => 3 } ) );

        $a_multi_pk_table = $skinny->search( 'c_multi_pk_table', { id_c => 1 } )->first;
        ok( $a_multi_pk_table );

        my ( $id_c, $id_d ) = ( $a_multi_pk_table->id_c, $a_multi_pk_table->id_d );

        $a_multi_pk_table->delete;

        ok ( not $skinny->single( 'c_multi_pk_table', { id_c => $id_c, id_d => $id_d } ) );

        done_testing();
    };

    subtest 'multi pk search_by_sql' => sub {
        my ( $itr, $row );

        $itr = $skinny->search_by_sql(q{SELECT * FROM c_multi_pk_table WHERE id_c = ? AND id_d = ?}, [3, 10], 'c_multi_pk_table');

        is( $itr->count, 1 );

        $row = $itr->first;
        is( $row->memo, 'foobar' );
        $row->update( { memo => 'hoge' } );

        $row = $skinny->search_by_sql(q{SELECT * FROM c_multi_pk_table WHERE id_c = ? AND id_d = ?}, [3, 10])->first;

        is( $row->memo, 'hoge' );

        done_testing();
    };

    subtest 'multi pk row insert' => sub {
        my ( $rs, $itr, $row );

        $row = $skinny->insert( 'c_multi_pk_table', { id_c => 3, id_d => 40 } );

        is_deeply( $row->get_columns, { id_c => 3, id_d => 40 } );

        $row->insert(); # find_or_create => find

        $itr = $skinny->search( 'c_multi_pk_table', { id_c => 3 } );
        is( $itr->count, 4 );

        $row->delete();

        $itr = $skinny->search( 'c_multi_pk_table', { id_c => 3 } );
        is( $itr->count, 3 );

        done_testing();
    };

    subtest 'multi pk find_or_create' => sub {
        my ( $rs, $itr, $row );

        {
            my $row = $skinny->find_or_create('c_multi_pk_table' => {id_c => 50, id_d => 90});
            $row->update({memo => 'yay'});
            is_deeply( $row->get_columns, { id_c => 50, id_d => 90, memo => 'yay' } );
        }

        {
            my $row = $skinny->find_or_create('c_multi_pk_table' => {id_c => 50, id_d => 90});
            is_deeply( $row->get_columns, { id_c => 50, id_d => 90, memo => 'yay' } );
        }

        done_testing();
    };
}

done_testing();

