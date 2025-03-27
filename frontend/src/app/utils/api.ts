export const getLoginCounts = async (location: string) => {
  const res = await fetch(`/api/loginCount?location=${location}`);
  const data = await res.json();
  return data.count;
};

export const getLocationData = async (location: string) => {
  const res = await fetch(`/api/locationData?location=${location}`);
  const data = await res.json();
  return data;
};

export const updateAlphaBeta = async (alpha: number, beta: number) => {
  await fetch(`/api/updateAlphaBeta`, {
    method: "POST",
    body: JSON.stringify({ alpha, beta }),
  });
};
