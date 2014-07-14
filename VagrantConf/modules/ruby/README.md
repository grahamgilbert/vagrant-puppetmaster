# Ruby Module

This module manages Ruby and Rubygems on Debian and Redhat based systems.

## Ruby

### Parameters

* *version*: (default installed) -
 Set the version of Ruby to install

 * *latest_release*: (default undefined) -
 Set this to true and the Ruby module will install new releases if they are updated in the repositories, or if a new repository is added with a newer release. Note: In Debian and Ubuntu where Ruby version is specified by package name, this parameter will effectively install the latest release of the Ruby version specified with the `version` parameter.

* *gems_version*: (default installed) -
 Set the version of Rubygems to be installed

* *rubygems_update*: (default true) -
 If set to true, the module will ensure that the rubygems package is installed
but will use rubygems-update (same as gem update --system but versionable) to
update Rubygems to the version defined in $gems_version.  If set to false then
the rubygems package resource will be versioned from $gems_version

* *ruby_package*: (default ruby) -
 Set the package name for ruby

* *rubygems_package*: (default rubygems) -
 Set the package name for rubygems

* *switch*: Installs `ruby-switch` and uses this to set the installed package as the system default. This may not be available for all distributions.

### Usage

For a standard install using the latest Rubygems provided by rubygems-update on
CentOS or Redhat use:  
```puppet
    class { 'ruby':
      gems_version  => 'latest'
    }
```

On Redhat this is equivilant to

    $ yum install ruby rubygems
    $ gem update --system

#### Specify Version

To install a specific version of ruby and rubygems but *not* use
rubygems-update use:  
```puppet
    class { 'ruby':
      version         => '1.8.7',
      gems_version    => '1.8.24',
      rubygems_update => false
    }
```

On Redhat this is equivilant to

    $ yum install ruby-1.8.7 rubygems-1.8.24

#### Alternative Ruby Packages

If you need to use different packages for either ruby or rubygems you
can. This could be for different versions or custom packages. For
instance the following installs ruby 1.9 on Ubuntu 12.04.  
```puppet
    class { 'ruby':
      ruby_package     => 'ruby1.9.1-full',
      rubygems_package => 'rubygems1.9.1',
      gems_version     => 'latest',
    }
```  
This parameter will be particularly important if an alternative package repository is defined with [`yumrepo`](http://docs.puppetlabs.com/references/latest/type.html#yumrepo) or [`apt::source` or `apt::ppa`](https://forge.puppetlabs.com/puppetlabs/apt).

## Ruby Configuration

Ruby Enterprise Edition, Ruby versions [later than 1.9.3-preview1](http://www.rubyinside.com/ruby-1-9-3-preview-1-released-5229.html), and some patched Ruby distributions allow some tuning of the Ruby memory heap and garbage collection. These features will not work with the standard Ruby distributions prior to 1.9.3.

The `ruby::config` class sets global environment variables that tune the Ruby memory heap and it's garbage collection as [per the Ruby Enterprise Edition documentation](http://www.rubyenterpriseedition.com/documentation.html#_garbage_collector_performance_tuning). This should allow the configuration of Ruby to better suit a deployed application and reduce the memory overhead of long-running Ruby processes (e.g. the [Puppet daemon](http://www.masterzen.fr/2010/01/28/puppet-memory-usage-not-a-fatality/)). The memory overhead issue can be further reduced by upgrading Ruby to a distribution using a [bitmap marked garbage collection](http://patshaughnessy.net/2012/3/23/why-you-should-be-excited-about-garbage-collection-in-ruby-2-0) patch (e.g. as provided by [BrightBox](http://docs.brightbox.com/ruby/ubuntu/)) or to [Ruby 2.x](https://www.ruby-lang.org/en/news/2013/02/24/ruby-2-0-0-p0-is-released/).

### More References

* [Demystifying the Ruby GC](http://samsaffron.com/archive/2013/11/22/demystifying-the-ruby-gc) by Sam Saffron

### Parameters

All the parameters are not set by default, which will revert to the default values for Ruby.

* *gc_malloc_limit* : Sets `RUBY_GC_MALLOC_LIMIT`, which is the amount of memory that can be allocated without triggering garbage collection. The default is 8000000.
* *heap_free_min* : Sets `RUBY_HEAP_FREE_MIN`, which is the number of heap slots that should be available after garbage collection is run. If fewer slots are available, new heap slots will be allocated. The default is 4096.
* *heap_slots_growth_factor* : Sets `RUBY_HEAP_SLOTS_GROWTH_FACTOR`, which is the multiplier for how many new slots to be created if fewer slots than `RUBY_HEAP_FREE_MIN` remain after garbage collection. The default is 1.8.
* *heap_min_slots* : This sets `RUBY_HEAP_MIN_SLOTS`, which is initial number of heap slots. The default is 10000.
* *heap_slots_increment* : This sets `RUBY_HEAP_SLOTS_INCREMENT`, which is the number of additional slots allocated the first time additional slots are required. The default is 10000.

### Usage

It should be possible to set any number of parameters, but setting no parameters is a special case that removes any modification to the Ruby environment settings.

#### No Parameters

If `ruby::config` is given with no parameters it removes the environment settings from the system, which restores the default Ruby settings.

```puppet
include ruby::config
```

#### With Parameters

```puppet
class {'ruby::config':
  heap_min_slots            => 500000,
  heap_slots_increment      => 250000,
  heap_slots_growth_factor  => 1,
  gc_malloc_limit           => 50000000,
}
```

Which should result with the following environment variables set:

```
RUBY_HEAP_MIN_SLOTS=500000
RUBY_HEAP_SLOTS_INCREMENT=250000
RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
RUBY_GC_MALLOC_LIMIT=50000000
```

# Package sources

If the required Ruby version is not available for the distribution being used check the following repositories:

* For Ubuntu Lucid onward: [Brightbox Ruby PPA](http://www.ubuntuupdates.org/ppa/brightbox_ruby_ng_experimental), use the following puppet code:  
```puppet
include apt
apt::ppa{'ppa:brightbox/ruby-ng-experimental':}
```