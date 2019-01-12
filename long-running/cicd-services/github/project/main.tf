resource "github_repository" "itds_github_prj_repo" {
  name = "${var.itds_github_prj_nm}"
  private = false
  has_issues = true
  has_wiki = true
  has_projects = true
  has_downloads = true
  auto_init = true
}

resource "github_team" "itds_github_prj_adm_tm" {
  name = "${github_repository.itds_github_prj_repo.name}-adm}"
  description = "Admin Team"
  privacy = "closed"
}

resource "github_team" "itds_github_prj_dev_tm" {
  name = "${github_repository.itds_github_prj_repo.name}-dev}"
  description = "Developer Team"
  privacy = "closed"
}

resource "github_team_repository" "itds_github_prj_adm_repo" {
  team_id = "${github_team.itds_github_prj_adm_tm.id}"
  repository = "${github_repository.itds_github_prj_repo.name}"
  permission = "admin"
}

resource "github_team_repository" "itds_github_prj_dev_repo" {
  team_id = "${github_team.itds_github_prj_dev_tm.id}"
  repository = "${github_repository.itds_github_prj_repo.name}"
  permission = "pull"
}


resource "github_repository_deploy_key" "itds_github_prj_repo_dpl_ky" {
  title = "${github_repository.itds_github_prj_repo.name} deploy key"
  repository = "${github_repository.itds_github_prj_repo.name}"
  key = "${file("${var.itds_github_prj_repo_dply_ky}")}"
  read_only = "true"

}
