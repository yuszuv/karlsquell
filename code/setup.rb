require 'logger'

require 'lib/client'

require 'lib/repos/tt_content_repo'
require 'lib/repos/page_repo'
require 'lib/repos/pages_language_overlay_repo'
require 'lib/repos/sys_history_repo'

require 'lib/transactions/delete_page_by_fe_group'
require 'lib/transactions/delete_tt_content_by_fe_group'
require 'lib/transactions/delete_page_with_subtree'
require 'lib/transactions/clean_up_tt_content'
require 'lib/transactions/clean_up_sys_history'

require 'lib/tag_stripper'

# deps
logger =
  Logger.new("| tee log/development.log")
logger.level = Logger::INFO

diff_logger =
  Logger.new("log/diff.log")

client =
  Client.new(logger)

# repos
tt_content_repo =
  TtContentRepo.new(client)
page_repo =
  PageRepo.new(client)
pages_language_overlay_repo =
  PagesLanguageOverlayRepo.new(client)
sys_history_repo =
  SysHistoryRepo.new(client)

# services
tag_stripper =
  TagStripper.new(diff_logger)
clean_up_tt_content =
  CleanUpTtContent.new(logger, tt_content_repo, tag_stripper)
clean_up_sys_history =
  CleanUpSysHistory.new(logger, sys_history_repo, tag_stripper)
delete_page_with_subtree =
  DeletePageWithSubtree.new(logger, page_repo, tt_content_repo, pages_language_overlay_repo)
delete_page_by_fe_group =
  DeletePageByFeGroup.new(logger, page_repo, delete_page_with_subtree)
delete_tt_content_by_fe_group =
  DeleteTtContentByFeGroup.new(logger, tt_content_repo)

# deps
$logger = logger
$diff_logger = diff_logger
$client = client

# services
$tag_stripper = tag_stripper
$clean_up_tt_content = clean_up_tt_content
$clean_up_sys_history = clean_up_sys_history
$delete_page_by_fe_group = delete_page_by_fe_group
$delete_page_with_subtree = delete_page_with_subtree
$delete_tt_content_by_fe_group = delete_tt_content_by_fe_group

#repos
$tt_content_repo = tt_content_repo
$page_repo = page_repo
$pages_language_overlay_repo = pages_language_overlay_repo
$sys_history_repo = sys_history_repo
