import { LightningElement, wire } from "lwc";
import getCases from "@salesforce/apex/cases.getCases";
import CASE_STATUS from "@salesforce/schema/Case.Status";
import { getPicklistValues } from "lightning/uiObjectInfoApi";

let DEFAULT_ACTIONS = [{ label: "All", checked: true, name: "all" }];

const columns = [
  { label: "CaseNumber", fieldName: "CaseNumber" },
  {
    label: "Status",
    fieldName: "Status",
    actions: DEFAULT_ACTIONS
  },
  { label: "Subject", fieldName: "Subject" },
  {
    label: "Priority",
    fieldName: "Priority",
    actions: [
      { label: "All", checked: true, name: "all" },
      { label: "Low", checked: false, name: "Low" },
      { label: "Medium", checked: false, name: "Medium" },
      { label: "High", checked: false, name: "High" }
    ]
  }
];

export default class Cases extends LightningElement {
  columns = columns;
  cases = [];
  ALL_CASES = [];
  latestActions = [];
  selectedActions = [];

  // flas
  showTable = false;

  @wire(getPicklistValues, {
    recordTypeId: "01290000001AjLGAA0",
    fieldApiName: CASE_STATUS
  })
  cases_status({ error, data }) {
    if (data) {
      data.values.forEach((pl) => {
        this.latestActions.push({
          label: pl.label,
          checked: false,
          name: pl.value
        });
      });
      this.columns.forEach((col) => {
        if (col.label === "Status") {
          col.actions = [...col.actions, ...this.latestActions];
        }
      });
      this.showTable = this.latestActions.length > 0;
    } else if (error) {
      console.error(error);
    }
  }

  @wire(getCases)
  wiredCases({ error, data }) {
    if (data) {
      console.log("cases data ", data);
      this.ALL_CASES = data;
      this.cases = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.contacts = undefined;
    }
  }

  handleHeaderAction(event) {
    console.log(JSON.stringify(event.detail.action));
    const actionName = event.detail.action.name;
    const colDef = event.detail.columnDefinition;
    const cols = this.columns;
    if (!this.selectedActions.includes(actionName)) {
      this.selectedActions.push(actionName);
    } else {
      const _idx = this.selectedActions.indexOf(actionName);
      this.selectedActions[_idx] = undefined;
    }

    if (actionName !== undefined && actionName !== "all") {
      this.cases = this.ALL_CASES.filter((_case) =>
        this.selectedActions.includes(_case[colDef.label])
      );
    } else if (actionName === "all") {
      this.cases = this.ALL_CASES;
      this.selectedActions = ["all"];
    }

    cols
      .find((col) => col.label === colDef.label)
      .actions.forEach(
        (action) =>
          (action.checked = this.selectedActions.includes(action.name))
      );

    this.columns = [...cols];
  }
}
