/*IMPORTS*/
//Bare Module Imports
import { LightningElement, api, wire } from "lwc";

// "lightning/*" imports
import LightningModal from 'lightning/modal';

// "@salesforce/*" imports
import CASE_OBJECT from '@salesforce/schema/Case';

// "c/*" imports
import { images } from "c/illustrationImage";
import ReusableModal from 'c/reusableModal';
/*IMPORTS*/

export default class ReusableEmptyState extends LightningElement {

  /*To be Removed*/
  @api fieldSetName;

  @api flexipageRegionWidth;

  /**
   * Text displayed below the image to describe why it is being displayed.
   * Should always be specified unless `textOnly` is `true`.
   *
   * @type {string}
   */
  @api heading;

  /**
   * Text displayed below `heading` to provide further description about the why
   * the illustration is being displayed. Can also be populated using a slot by
   * the same name to include links or other rich text. If this property and the
   * slot are populated, the slot content takes precedence.
   *
   * @type {string}
   */
  @api messageBody;

  /**
   * The identifier for the illustration image to show, in the format
   * `[category]:[description]`. See
   * https://www.lightningdesignsystem.com/components/illustration/ for what
   * each option renders.
   *
   * @type {keyof images}
   */
  @api imageName;

  /**
   * The size of the image.
   *
   * @default small
   * @type {"small"|"large"}
   */
  @api imageSize = "small";

  /**
   * Whether or not the image should be hidden from the layout.
   *
   * @default false
   * @type {boolean}
   */
  @api textOnly = false;

  /**
   * Whether call to action should be shown
   * Currently, only support Case Creation
   * @default false
   * @type {boolean}
   */
  @api showCallToAction;

  /**
   * Object for which record needs to be
   * created from CTA, only supports Case currently
   * @default false
   * @type {boolean}
  */
  @api objectName = 'Case';


  @api caseDescription;
  @api caseTopic;
  @api isManualCase;

  modalLabel = 'Create Case';

  get rootClass() {
    return `slds-illustration slds-illustration_${this.imageSize}`;
  }

  async createCase() {
      const result = await ReusableModal.open(
          {
              label: this.modalLabel,
              description: 'Case Creation Flow'
          }
      );
  }

}