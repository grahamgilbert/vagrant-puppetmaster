# This is an example of a very basic 3-node setup for puppetdb.

# This node is our puppet master.
node puppet {
    # Here we configure the puppet master to use puppetdb.
    class { 'puppetdb::master::config':
        puppetdb_server => 'puppetdb',
    }
}

# This node is our postgres server
node puppetdb-postgres {
    # Here we install and configure postgres and the puppetdb database instance
    # Optionally, open the firewall port for postgres so puppetdb server can 
    # gain access.
    class { 'puppetdb::database::postgresql':
        listen_addresses       => 'puppetdb-postgres',
        manage_redhat_firewall => true,
    }
}

# This node is our main puppetdb server
node puppetdb {
    # Here we install and configure the puppetdb server, and tell it where to
    # find the postgres database.
    # Set open_ssl_listen_port to allow the puppet master to gain access to 
    # puppetdb.  Optionally, set open_listen_port to open the HTTP port so 
    # you can access the PuppetDB dashboard.
    class { 'puppetdb::server':
        database_host        => 'puppetdb-postgres',
        open_ssl_listen_port => true,
        open_listen_port     => true,
    }
}
