/**
 * Created by fheeneman on 23/8/23.
 */

public without sharing class KnowledgePublishingService implements Database.Batchable<sObject>, Database.Stateful {
    public final String query;
    public final String operation;

    private Integer successes;
    private Integer errors;

    /**
     * @param query Determines the scope of the batch, needs query Knowledge__kav
     * @param operation Determines the operation to be executed on the batch, possible options: <br />
     *  <ul>
     *      <li>'deleteDrafts' - Deletes draft articles or translations, depending on the scope (determined by IsMasterLanguage)</li>
     *      <li>'publish' - Publishes draft articles </li>
     *      <li>'archive' - Archives published (status Online) articles</li>
     *  </ul>
     *
     */
    public KnowledgePublishingService(String query, String operation) {
        this.query = query;
        this.operation = operation;
        this.successes = 0;
        this.errors = 0;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext batchableContext, List<sObject> scope) {
        List<Knowledge__kav> articles = (List<Knowledge__kav>) scope;
        if (operation == 'deleteDrafts') {
            for (Knowledge__kav article : articles) {
                try {
                    if (article.IsMasterLanguage) {
                        KbManagement.PublishingService.deleteDraftArticle(article.KnowledgeArticleId);
                    } else {
                        KbManagement.PublishingService.deleteDraftTranslation(article.Id);
                    }
                    successes++;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                    errors++;
                }
            }
        } else if (operation == 'publish') {
            for (Knowledge__kav article : articles) {
                try {
                    if (article.IsMasterLanguage) {
                        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);
                    } else {
                        KbManagement.PublishingService.completeTranslation(article.Id);
                    }
                    successes++;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                    errors++;
                }
            }
        } else if (operation == 'archive') {
            for (Knowledge__kav article : articles) {
                try {
                    KbManagement.PublishingService.archiveOnlineArticle(article.KnowledgeArticleId, null);
                    successes++;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                    errors++;
                }
            }
        } else if (operation == 'createDrafts') {
            for (Knowledge__kav article : articles) {
                try {
                    if (article.IsMasterLanguage) {
                        KbManagement.PublishingService.editOnlineArticle(article.KnowledgeArticleId, false);
                    } else {
                        KbManagement.PublishingService.editPublishedTranslation(article.KnowledgeArticleId, article.Language, false);
                    }
                    successes++;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                    errors++;
                }
            }
        }
        System.debug('Successes: ' + successes + '\nErrors: ' + errors);
    }

    public void finish(Database.BatchableContext batchableContext) {
        System.debug('Successes: ' + successes + '\nErrors: ' + errors);
    }

}