import { Application } from "@hotwired/stimulus"; // 👈 Línea faltante
import EchartController from "./echart_controller";

const application = Application.start(); // 👈 Línea faltante
application.register("echart", EchartController);

// Opcional para debug (accesible desde consola)
window.Stimulus = application;
