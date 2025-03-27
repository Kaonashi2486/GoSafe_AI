"use client";

import { motion } from "framer-motion";
import { ReactNode } from "react";

interface SlideInProps {
  children: ReactNode;
  direction?: "left" | "right" | "up" | "down";
  delay?: number;
  duration?: number;
}

export default function SlideIn({
  children,
  direction = "left",
  delay = 0,
  duration = 0.5,
}: SlideInProps) {
  const variants = {
    left: { opacity: 0, x: -50 },
    right: { opacity: 0, x: 50 },
    up: { opacity: 0, y: 50 },
    down: { opacity: 0, y: -50 },
  };

  return (
    <motion.div
      initial={variants[direction]}
      animate={{ opacity: 1, x: 0, y: 0 }}
      transition={{ duration, delay }}
    >
      {children}
    </motion.div>
  );
}
