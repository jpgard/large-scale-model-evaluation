results = "/Users/joshgardner/Documents/UM-Graduate/UMSI/LED_Lab/jla-model-eval/experiment-results-analysis/complete_comparison_results.csv"
results = read.csv(results, stringsAsFactors = F)
OUTDIR = "/Users/joshgardner/Documents/UM-Graduate/UMSI/LED_Lab/jla-model-eval/experiment-results-analysis/"
# preprocessing
cd_col = names(results)[grep("rank_x.rank_y_greater_cd", names(results))]
results[cd_col] = ifelse(results[cd_col] == "False", F, T) # indicator for whether difference is statistically significant/whether NHST makes a decision
BDT = 0.95 # bayesian decision threshold
results$bayes_decision = factor(ifelse(results$left > BDT, "left", ifelse(results$rope > BDT, "rope", ifelse(results$right > BDT, "right", "none")))) # indicator for whether Bayesian makes a decision and what that decision is

library(dplyr)
library(ggplot2)
# fetch best model by AUC; family of best models is defined as those with performance statistically indistinguishable from this model
best_model_id = dplyr::top_n(results, 1, avg_auc_x)$model_id_x[1]
# percentage of comparisons where NHST makes a decision
nhst_decisions = mean(results[,cd_col])
print(paste0("NHST procedure decides in ", round(nhst_decisions, 4), " of ", nrow(results), " cases"))
best_model_df_nhst = results[(results["model_id_x"] == best_model_id) & (results[cd_col] == F),]
write.csv(best_model_df_nhst, file=paste0(OUTDIR, "best_model_family_nhst.csv"))

# percentage of comparisons where bayesian model eval makes a decision
bayesian_decisions = mean(results$bayes_decision %in% c("left", "right", "rope"))
print(paste0("Bayesian procedure decides in ", round(bayesian_decisions, 4), " of ", nrow(results), " cases"))
best_model_df_bayesian = results[(results["model_id_x"] == best_model_id) & (results["bayes_decision"] == "rope"),]
write.csv(best_model_df_bayesian, file=paste0(OUTDIR, "best_model_family_bayesian.csv"))

frequentist_windowpane_plot <- function(df){
    use_cols = c("model_id_x", "model_id_y","ROC_rank_x", "ROC_rank_y", cd_col)
    temp = dplyr::select(results, one_of(use_cols)) 
    # create a second dataframe with same model_ids, but permuted (also permute ranks)
    temp2 = data.frame("model_id_x" = temp$model_id_y, "model_id_y" = temp$model_id_x, "ROC_rank_x" = temp$ROC_rank_y, "ROC_rank_y" = temp$ROC_rank_x, temp$rank_x.rank_y_greater_cd_26.0268)
    # join into single dataframe; now we have all permutations of both models
    complete_comparison_mx = rbind(temp, temp2)
    complete_comparison_mx$ind = ifelse(complete_comparison_mx$rank_x.rank_y_greater_cd_26.0268 == F, "ND", ifelse(complete_comparison_mx$ROC_rank_x > complete_comparison_mx$ROC_rank_y, "GT", "LT"))
    # create dataframe of model_ids
    model_number_df = complete_comparison_mx %>% 
        dplyr::select(one_of(c("model_id_x", "ROC_rank_x"))) %>% 
        dplyr::rename(model_id=model_id_x) %>%
        unique() %>% 
        arrange(ROC_rank_x)
    model_number_df$model_num = seq(nrow(model_number_df))
    # model id for x
    complete_comparison_mx = merge(complete_comparison_mx, model_number_df, by.x = "model_id_x", by.y = "model_id")
    names(complete_comparison_mx)[names(complete_comparison_mx) == "model_num"] <- "model_num_x"
    # model id for y
    complete_comparison_mx = merge(complete_comparison_mx, model_number_df, by.x = "model_id_y", by.y = "model_id")
    names(complete_comparison_mx)[names(complete_comparison_mx) == "model_num"] <- "model_num_y"
    # create nice names for plotting; only needed for model_id_y (model_id_x names not shown in plot)
    complete_comparison_mx$model_id_y_withnum = factor(paste0(complete_comparison_mx$model_id_y, " (", complete_comparison_mx$model_num_y, ")"))
    #plot
    ggplot(complete_comparison_mx, aes(x = reorder(model_id_x, -ROC_rank_x), y = reorder(model_id_y_withnum, -ROC_rank_y), fill = factor(ind))) + 
        geom_tile() + 
        geom_text(aes(label = model_num_x), size=1.75) + 
        scale_fill_manual(labels = c("Y > X", "Y < X", "No Decision"), values=c("#E69F00", "#56B4E9", "#FFFFFF")) + 
        theme(panel.background = element_rect(fill="white"), 
              axis.text = element_text(size=rel(0.85)), 
              plot.title=element_text(hjust = 0.5, size = rel(2)), 
              axis.text.x = element_blank(), 
              axis.ticks = element_blank(),
              axis.title.x = element_blank(),
              axis.title.y = element_blank()) + 
        ggtitle("Frequentist Model Decisions") +
        labs(fill = "Frequentist Decision")
}

frequentist_windowpane_plot(results)



library(ggplot2)
# plots
#TODO: this should go in a separate script
freq_windowpane_plot <- function(df){
    # order by performance
    df$model_id_x = reorder(df$model_id_x, df$ROC_rank_x)
    df$model_id_y = reorder(df$model_id_y, df$ROC_rank_y)
    # subset columns
    use_cols = c("model_id_x", "model_id_y", cd_col)
    df = dplyr::select(df, one_of(use_cols))
    df_permute = df[,c(2,1,3)]
    df = rbind(df, df_permute)
    #frequentist
    ggplot(df, aes(y = , x = model_id_x, fill = cd_col)) + geom_tile() + theme(axis.text.x = element_text(angle=45, hjust=1, vjust=1))
}

ggplot(df, aes(y = model_id_y, x = model_id_x, fill = bayes_decision)) + geom_tile() + theme(axis.text.x = element_text(angle=90, hjust=1, vjust=1))
ggplot(df, aes(y = reorder(model_id_y, -ROC_rank_y), x = reorder(model_id_x, -ROC_rank_x), fill = bayes_decision)) + geom_tile() + theme(axis.text.x = element_text(angle=90, hjust=1, vjust=1))

