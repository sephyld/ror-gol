import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "sub"];

  timer = null;

  togglePlay(event) {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
      this.buttonTarget.textContent = ">";
    } else {
      this.timer = setInterval(() => this.clickFormSubmition(), 500);
      this.buttonTarget.textContent = "||";
    }
  }

  clickFormSubmition() {
    this.subTarget.click();
  }

}
