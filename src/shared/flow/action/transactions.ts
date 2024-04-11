import type { TokenIdentity } from "@shared/flow/entities";
import { FilterType } from "@shared/flow/enums";
import type { FlowService } from "@shared/flow/flow.service";
// Transactions
import txRegisterStandardFT from "@cadence/transactions/register-standard-ft.cdc?raw";
import txReviewerPublishMaintainer from "@cadence/transactions/reviewer-publish-maintainer.cdc?raw";
import txMaintainerClaim from "@cadence/transactions/maintainer-claim.cdc?raw";
import txMaintainerRegisterCustomizedFT from "@cadence/transactions/maintainer-register-customized-ft.cdc?raw";
import txMaintainerUpdateCustomizedFT from "@cadence/transactions/maintainer-update-customized-ft.cdc?raw";
import txMaintainerUpdateReviewerMetadata from "@cadence/transactions/maintainer-update-reviewer-metadata.cdc?raw";

/** ---- Transactions ---- */
