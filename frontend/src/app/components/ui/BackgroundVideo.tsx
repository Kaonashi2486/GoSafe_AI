const BackgroundVideo: React.FC = () => {
  return (
    <div className="absolute top-0 left-0 w-full h-full">
      <video
        autoPlay
        loop
        muted
        playsInline
        className="w-full h-full object-cover opacity-70"
      >
        <source src="/walking.mp4" type="video/mp4" />
        Your browser does not support the video tag.
      </video>
    </div>
  );
};

export default BackgroundVideo;
