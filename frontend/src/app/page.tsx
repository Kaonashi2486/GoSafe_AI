import Hero from "../app/components/Hero";
import About from "../app/components/About";
import Features from "../app/components/Features";
import Contact from "../app/components/Contact";
import BackgroundVideo from "./components/ui/BackgroundVideo";
import Footer from "./components/Footer";
import Navbar from "./components/Navbar";
import SlideIn from "./components/SlideIn";

export default function Home() {
  return (
    <>
    <SlideIn direction="left">
    <main className="bg-gray-900 text-white">
      <></>
      <Navbar />
      {/* <BackgroundVideo /> */}
      <Hero />
      <About />
      <section className="py-16 bg-gray-800 text-white text-center">
      <div className="max-w-3xl mx-auto">
        <h2 className="text-3xl font-bold text-blue-300">Why Choose GoSafe AI?</h2>
        <p className="text-lg mt-4 text-blue-200">
          Traveling should be safe and stress-free. GoSafe AI provides <b>data-driven risk assessments</b>,  
          <b>personalized travel recommendations</b>, and <b>emergency alerts</b> to help you stay secure  
          anywhere in the world.
        </p>
      </div>
    </section>
      <Features />
      <Contact />
      <Footer />
    </main>
    </SlideIn>
    </>
  );
}

