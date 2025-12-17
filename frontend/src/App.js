import React, { useState, useEffect } from 'react';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL;

function App() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [newUser, setNewUser] = useState({ name: '', email: '' });
  const [pollyText, setPollyText] = useState('');
  const [pollyVoice, setPollyVoice] = useState('Joanna');
  const [comprehendText, setComprehendText] = useState('');
  const [sentiment, setSentiment] = useState(null);
  const [audioUrl, setAudioUrl] = useState(null);

  // Fetch users on load
  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const response = await fetch(`${API_URL}/users`);
      const data = await response.json();
      setUsers(data.users || []);
    } catch (error) {
      console.error('Error fetching users:', error);
      alert('Error fetching users');
    }
    setLoading(false);
  };

  const createUser = async (e) => {
    e.preventDefault();
    if (!newUser.name || !newUser.email) {
      alert('Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch(`${API_URL}/users`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newUser)
      });
      const data = await response.json();
      
      if (response.ok) {
        alert('User created successfully!');
        setNewUser({ name: '', email: '' });
        fetchUsers();
      } else {
        alert('Error creating user: ' + (data.error || 'Unknown error'));
      }
    } catch (error) {
      console.error('Error creating user:', error);
      alert('Error creating user');
    }
    setLoading(false);
  };

  const generateSpeech = async () => {
    if (!pollyText) {
      alert('Please enter text to convert to speech');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch(`${API_URL}/polly`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: pollyText, voiceId: pollyVoice })
      });
      const data = await response.json();

      if (response.ok) {
        // Convert base64 to blob and create URL
        const audioData = atob(data.audioContent);
        const arrayBuffer = new ArrayBuffer(audioData.length);
        const view = new Uint8Array(arrayBuffer);
        for (let i = 0; i < audioData.length; i++) {
          view[i] = audioData.charCodeAt(i);
        }
        const blob = new Blob([arrayBuffer], { type: 'audio/mpeg' });
        const url = URL.createObjectURL(blob);
        setAudioUrl(url);
      } else {
        alert('Error generating speech: ' + (data.error || 'Unknown error'));
      }
    } catch (error) {
      console.error('Error generating speech:', error);
      alert('Error generating speech');
    }
    setLoading(false);
  };

  const analyzeSentiment = async () => {
    if (!comprehendText) {
      alert('Please enter text to analyze');
      return;
    }

    setLoading(true);
    setSentiment(null);
    try {
      const response = await fetch(`${API_URL}/comprehend`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: comprehendText })
      });
      const data = await response.json();

      if (response.ok) {
        setSentiment(data);
      } else {
        alert('Error analyzing sentiment: ' + (data.error || 'Unknown error'));
      }
    } catch (error) {
      console.error('Error analyzing sentiment:', error);
      alert('Error analyzing sentiment');
    }
    setLoading(false);
  };

  const getSentimentColor = (sentimentType) => {
    const colors = {
      POSITIVE: '#4ade80',
      NEGATIVE: '#f87171',
      NEUTRAL: '#94a3b8',
      MIXED: '#fbbf24'
    };
    return colors[sentimentType] || '#94a3b8';
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1> Assessment II: Serverless App</h1>
        <p>AWS Lambda + API Gateway + DynamoDB + AI Services</p>
      </header>

      <main className="App-main">
        {/* User Management Section */}
        <section className="section">
          <h2> User Management</h2>
          
          <div className="card">
            <h3>Create New User</h3>
            <form onSubmit={createUser}>
              <input
                type="text"
                placeholder="Name"
                value={newUser.name}
                onChange={(e) => setNewUser({ ...newUser, name: e.target.value })}
                disabled={loading}
              />
              <input
                type="email"
                placeholder="Email"
                value={newUser.email}
                onChange={(e) => setNewUser({ ...newUser, email: e.target.value })}
                disabled={loading}
              />
              <button type="submit" disabled={loading}>
                {loading ? 'Creating...' : 'Create User'}
              </button>
            </form>
          </div>

          <div className="card">
            <h3>User List ({users.length})</h3>
            {loading && users.length === 0 ? (
              <p>Loading users...</p>
            ) : users.length === 0 ? (
              <p>No users yet. Create one above!</p>
            ) : (
              <div className="user-list">
                {users.map((user) => (
                  <div key={user.userId} className="user-item">
                    <strong>{user.name}</strong>
                    <span>{user.email}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </section>

        {/* Polly TTS Section */}
        <section className="section">
          <h2> Text-to-Speech (Amazon Polly)</h2>
          
          <div className="card">
            <textarea
              placeholder="Enter text to convert to speech..."
              value={pollyText}
              onChange={(e) => setPollyText(e.target.value)}
              rows="4"
              disabled={loading}
            />
            
            <div className="voice-selector">
              <label>Voice: </label>
              <select 
                value={pollyVoice} 
                onChange={(e) => setPollyVoice(e.target.value)}
                disabled={loading}
              >
                <option value="Joanna">Joanna (Female, US)</option>
                <option value="Matthew">Matthew (Male, US)</option>
                <option value="Amy">Amy (Female, UK)</option>
                <option value="Brian">Brian (Male, UK)</option>
                <option value="Kendra">Kendra (Female, US)</option>
                <option value="Kevin">Kevin (Male, US)</option>
              </select>
            </div>

            <button onClick={generateSpeech} disabled={loading || !pollyText}>
              {loading ? 'Generating...' : ' Generate Speech'}
            </button>

            {audioUrl && (
              <div className="audio-player">
                <audio controls src={audioUrl} autoPlay>
                  Your browser does not support audio playback.
                </audio>
              </div>
            )}
          </div>
        </section>

        {/* Comprehend Sentiment Section */}
        <section className="section">
          <h2> Sentiment Analysis (Amazon Comprehend)</h2>
          
          <div className="card">
            <textarea
              placeholder="Enter text to analyze sentiment..."
              value={comprehendText}
              onChange={(e) => setComprehendText(e.target.value)}
              rows="4"
              disabled={loading}
            />

            <button onClick={analyzeSentiment} disabled={loading || !comprehendText}>
              {loading ? 'Analyzing...' : '🔍 Analyze Sentiment'}
            </button>

            {sentiment && (
              <div className="sentiment-result">
                <div 
                  className="sentiment-badge"
                  style={{ backgroundColor: getSentimentColor(sentiment.sentiment) }}
                >
                  {sentiment.sentiment}
                </div>
                
                <div className="sentiment-scores">
                  <div className="score-item">
                    <span>Positive:</span>
                    <div className="score-bar">
                      <div 
                        className="score-fill positive"
                        style={{ width: `${sentiment.scores.positive * 100}%` }}
                      />
                    </div>
                    <span>{(sentiment.scores.positive * 100).toFixed(1)}%</span>
                  </div>
                  
                  <div className="score-item">
                    <span>Negative:</span>
                    <div className="score-bar">
                      <div 
                        className="score-fill negative"
                        style={{ width: `${sentiment.scores.negative * 100}%` }}
                      />
                    </div>
                    <span>{(sentiment.scores.negative * 100).toFixed(1)}%</span>
                  </div>
                  
                  <div className="score-item">
                    <span>Neutral:</span>
                    <div className="score-bar">
                      <div 
                        className="score-fill neutral"
                        style={{ width: `${sentiment.scores.neutral * 100}%` }}
                      />
                    </div>
                    <span>{(sentiment.scores.neutral * 100).toFixed(1)}%</span>
                  </div>
                  
                  <div className="score-item">
                    <span>Mixed:</span>
                    <div className="score-bar">
                      <div 
                        className="score-fill mixed"
                        style={{ width: `${sentiment.scores.mixed * 100}%` }}
                      />
                    </div>
                    <span>{(sentiment.scores.mixed * 100).toFixed(1)}%</span>
                  </div>
                </div>
              </div>
            )}
          </div>
        </section>
      </main>

      <footer className="App-footer">
        <p>Built with React + Terraform + AWS Lambda + API Gateway + DynamoDB</p>
        <p>George Villanueva - Code Platoon Assessment II</p>
      </footer>
    </div>
  );
}

export default App;
