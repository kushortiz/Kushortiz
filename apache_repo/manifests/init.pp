include stdlib

class apache_repo() {

    include ::apache_repo::environment_params
    include ::apache_repo::prereq_checks

}
