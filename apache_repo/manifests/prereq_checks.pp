class apache_repo::prereq_checks {

package { 'pcre':
  name    => 'pcre',
}

package { 'pcre-devel':
  name    => 'pcre-devel',
}

package { 'gcc':
  name    => 'gcc',
}
}
