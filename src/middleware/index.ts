import { sequence } from "astro:middleware";
import filter from "./filter";
import normalize from "./normalize";
import validation from "./validation";

export const onRequest = sequence(filter, normalize, validation);
